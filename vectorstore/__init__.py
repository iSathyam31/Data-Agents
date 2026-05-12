"""ChromaDB vector store for knowledge and learnings — uses Azure OpenAI embeddings."""

import chromadb
from chromadb.utils.embedding_functions import OpenAIEmbeddingFunction
import config

# ── Singletons ────────────────────────────────────────────────────
_client = None
_embedding_fn = None
_knowledge_collection = None
_learnings_collection = None


def _get_embedding_fn() -> OpenAIEmbeddingFunction:
    """Create Azure OpenAI-compatible embedding function for ChromaDB (cached)."""
    global _embedding_fn
    if _embedding_fn is None:
        _embedding_fn = OpenAIEmbeddingFunction(
            api_key=config.AZURE_OPENAI_API_KEY,
            api_base=config.AZURE_OPENAI_ENDPOINT,
            api_type="azure",
            api_version=config.AZURE_OPENAI_API_VERSION,
            model_name=config.AZURE_OPENAI_EMBEDDING_DEPLOYMENT,
            deployment_id=config.AZURE_OPENAI_EMBEDDING_DEPLOYMENT,
        )
    return _embedding_fn


def get_client() -> chromadb.ClientAPI:
    """Get persistent ChromaDB client (singleton)."""
    global _client
    if _client is None:
        _client = chromadb.PersistentClient(path=config.CHROMA_PERSIST_DIR)
    return _client


def get_knowledge_collection():
    """Get or create the knowledge collection (cached)."""
    global _knowledge_collection
    if _knowledge_collection is None:
        client = get_client()
        _knowledge_collection = client.get_or_create_collection(
            name="knowledge",
            embedding_function=_get_embedding_fn(),
            metadata={"hnsw:space": "cosine"},
        )
    return _knowledge_collection


def get_learnings_collection():
    """Get or create the learnings collection (cached)."""
    global _learnings_collection
    if _learnings_collection is None:
        client = get_client()
        _learnings_collection = client.get_or_create_collection(
            name="learnings",
            embedding_function=_get_embedding_fn(),
            metadata={"hnsw:space": "cosine"},
        )
    return _learnings_collection


def search_knowledge(query: str, n_results: int | None = None) -> list[dict]:
    """Search knowledge base. Returns list of {id, document, metadata, distance}."""
    n = n_results or config.KNOWLEDGE_TOP_K
    collection = get_knowledge_collection()
    if collection.count() == 0:
        return []
    results = collection.query(query_texts=[query], n_results=min(n, collection.count()))
    items = []
    for i in range(len(results["ids"][0])):
        items.append({
            "id": results["ids"][0][i],
            "document": results["documents"][0][i],
            "metadata": results["metadatas"][0][i] if results["metadatas"] else {},
            "distance": results["distances"][0][i] if results["distances"] else None,
        })
    return items


def search_learnings(query: str, n_results: int | None = None) -> list[dict]:
    """Search learnings store. Returns list of {id, document, metadata, distance}."""
    n = n_results or config.LEARNINGS_TOP_K
    collection = get_learnings_collection()
    if collection.count() == 0:
        return []
    results = collection.query(query_texts=[query], n_results=min(n, collection.count()))
    items = []
    for i in range(len(results["ids"][0])):
        items.append({
            "id": results["ids"][0][i],
            "document": results["documents"][0][i],
            "metadata": results["metadatas"][0][i] if results["metadatas"] else {},
            "distance": results["distances"][0][i] if results["distances"] else None,
        })
    return items


def save_learning(learning_id: str, text: str, metadata: dict | None = None):
    """Save a learning to the learnings collection."""
    collection = get_learnings_collection()
    collection.upsert(
        ids=[learning_id],
        documents=[text],
        metadatas=[metadata or {}],
    )


def upsert_knowledge(doc_id: str, text: str, metadata: dict | None = None):
    """Upsert a knowledge document."""
    collection = get_knowledge_collection()
    collection.upsert(
        ids=[doc_id],
        documents=[text],
        metadatas=[metadata or {}],
    )
