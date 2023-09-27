from pydantic import BaseModel


class ErrorDetail(BaseModel):
    loc: list[str]
    msg: str
    type: str


# Override the default ValidationError response to work with openapi-generator.
# In particular, we cannot have an anyOf type for the location field.
# TODO: Work on the error response
class ValidationError(BaseModel):
    detail: list[ErrorDetail]
    body: str
