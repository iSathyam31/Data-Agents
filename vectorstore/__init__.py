"""Qdrant vector store for knowledge and learnings — uses Azure OpenAI embeddings."""

from langchain_openai import AzureOpenAIEmbeddings
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct
import config
import uuid

# ── Singletons ────────────────────────────────────────────────────
_client = None
_embeddings = None
NAMESPACE_QDRANT = uuid.UUID("12345678-1234-5678-1234-567812345678")


def _get_uuid(text_id: str) -> str:
    """Generate a deterministic UUID from a string ID for Qdrant."""
    return str(uuid.uuid5(NAMESPACE_QDRANT, text_id))


def _get_embeddings() -> AzureOpenAIEmbeddings:
    """Create Azure OpenAI embeddings generator (cached)."""
    global _embeddings
    if _embeddings is None:
        _embeddings = AzureOpenAIEmbeddings(
            api_key=config.AZURE_OPENAI_API_KEY,
            azure_endpoint=config.AZURE_OPENAI_ENDPOINT,
            azure_deployment=config.AZURE_OPENAI_EMBEDDING_DEPLOYMENT,
            api_version=config.AZURE_OPENAI_API_VERSION,
        )
    return _embeddings


def get_client() -> QdrantClient:
    """Get persistent Qdrant client (singleton)."""
    global _client
    if _client is None:
        if config.QDRANT_URL and config.QDRANT_API_KEY:
            _client = QdrantClient(url=config.QDRANT_URL, api_key=config.QDRANT_API_KEY)
        else:
            # Fallback to local memory if not configured (for dev)
            _client = QdrantClient(":memory:")
    return _client


def _ensure_collection(name: str):
    """Ensure the Qdrant collection exists with the correct vector size."""
    client = get_client()
    if not client.collection_exists(name):
        client.create_collection(
            collection_name=name,
            vectors_config=VectorParams(size=1536, distance=Distance.COSINE),
        )


def clear_knowledge():
    """Clear all documents in the knowledge collection."""
    client = get_client()
    if client.collection_exists("knowledge"):
        client.delete_collection("knowledge")
        _ensure_collection("knowledge")


def search_knowledge(query: str, n_results: int | None = None) -> list[dict]:
    """Search knowledge base. Returns list of {id, document, metadata, distance}."""
    n = n_results or config.KNOWLEDGE_TOP_K
    _ensure_collection("knowledge")
    client = get_client()
    
    # Qdrant raises an error if we try to search an empty in-memory collection
    try:
        query_vector = _get_embeddings().embed_query(query)
        results = client.query_points(
            collection_name="knowledge",
            query=query_vector,
            limit=n
        ).points
    except Exception:
        return []

    items = []
    for hit in results:
        items.append({
            "id": hit.payload.get("original_id", hit.id),
            "document": hit.payload.get("document", ""),
            "metadata": hit.payload.get("metadata", {}),
            "distance": hit.score,
        })
    return items


def search_learnings(query: str, n_results: int | None = None) -> list[dict]:
    """Search learnings store. Returns list of {id, document, metadata, distance}."""
    n = n_results or config.LEARNINGS_TOP_K
    _ensure_collection("learnings")
    client = get_client()
    
    try:
        query_vector = _get_embeddings().embed_query(query)
        results = client.query_points(
            collection_name="learnings",
            query=query_vector,
            limit=n
        ).points
    except Exception:
        return []

    items = []
    for hit in results:
        items.append({
            "id": hit.payload.get("original_id", hit.id),
            "document": hit.payload.get("document", ""),
            "metadata": hit.payload.get("metadata", {}),
            "distance": hit.score,
        })
    return items


def save_learning(learning_id: str, text: str, metadata: dict | None = None):
    """Save a learning to the learnings collection."""
    _ensure_collection("learnings")
    vector = _get_embeddings().embed_query(text)
    
    payload = {"document": text, "metadata": metadata or {}, "original_id": learning_id}
    
    get_client().upsert(
        collection_name="learnings",
        points=[
            PointStruct(
                id=_get_uuid(learning_id),
                vector=vector,
                payload=payload
            )
        ]
    )


def upsert_knowledge(doc_id: str, text: str, metadata: dict | None = None):
    """Upsert a knowledge document."""
    _ensure_collection("knowledge")
    vector = _get_embeddings().embed_query(text)
    
    payload = {"document": text, "metadata": metadata or {}, "original_id": doc_id}
    
    get_client().upsert(
        collection_name="knowledge",
        points=[
            PointStruct(
                id=_get_uuid(doc_id),
                vector=vector,
                payload=payload
            )
        ]
    )

