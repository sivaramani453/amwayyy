from typing import Any, Dict

from github.GithubObject import NonCompletableGithubObject

class Path(NonCompletableGithubObject):
    def __repr__(self) -> str: ...
    def _initAttributes(self) -> None: ...
    def _useAttributes(self, attributes: Dict[str, Any]) -> None: ...
    @property
    def count(self) -> int: ...
    @property
    def path(self) -> str: ...
    @property
    def title(self) -> str: ...
    @property
    def uniques(self) -> int: ...
