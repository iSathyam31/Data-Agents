"""ChromaDB client and collections for knowledge and learnings."""

import chromadb
from openai import AzureOpenAI

from dash_strands import config


class AzureEmbeddingFunction(chromadb.EmbeddingFunction):
    """Embedding function using Azure OpenAI."""

    def __init__(self):
        self.client = AzureOpenAI(
            api_key=config.EMBEDDING_API_KEY,
            azure_endpoint=config.EMBEDDING_ENDPOINT,
            api_version=config.EMBEDDING_API_VERSION,
        )
        self.model = config.EMBEDDING_DEPLOYMENT

    def __call__(self, input: list[str]) -> list[list[float]]:
        response = self.client.embeddings.create(input=input, model=self.model)
        return [item.embedding for item in response.data]


_chroma_client = None
_embedding_fn = None


def _get_chroma_client() -> chromadb.PersistentClient:
    global _chroma_client
    if _chroma_client is None:
        _chroma_client = chromadb.PersistentClient(path=config.CHROMA_PATH)
    return _chroma_client


def _get_embedding_fn() -> AzureEmbeddingFunction:
    global _embedding_fn
    if _embedding_fn is None:
        _embedding_fn = AzureEmbeddingFunction()
    return _embedding_fn


def get_knowledge_collection():
    """Curated knowledge: table metadata, validated queries, business rules, dash objects."""
    return _get_chroma_client().get_or_create_collection(
        name="dash_knowledge",
        embedding_function=_get_embedding_fn(),
    )


def get_learnings_collection():
    """Discovered learnings: error patterns, fixes, gotchas."""
    return _get_chroma_client().get_or_create_collection(
        name="dash_learnings",
        embedding_function=_get_embedding_fn(),
    )
