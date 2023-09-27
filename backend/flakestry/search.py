from functools import lru_cache
import os
from opensearchpy import OpenSearch

opensearch_index = "flakes"


@lru_cache()
def get_opensearch():
    host = os.environ.get("OPENSEARCH_HOST", "localhost")
    opensearch = OpenSearch(
        hosts=[{"host": host, "port": 9200}],
    )

    if not opensearch.indices.exists(index=opensearch_index):
        opensearch.indices.create(opensearch_index, body={})
    return opensearch
