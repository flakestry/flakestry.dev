from functools import lru_cache
from opensearchpy import OpenSearch

opensearch_index = "flakes"

@lru_cache()
def get_opensearch():
    opensearch = OpenSearch(
        hosts = [{'host': 'localhost', 'port': 9200}],
    )

    if not opensearch.indices.exists(index=opensearch_index):
        opensearch.indices.create(opensearch_index, body={})
    return opensearch

