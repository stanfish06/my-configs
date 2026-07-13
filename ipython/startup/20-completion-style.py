from prompt_toolkit.styles import Style as _PromptToolkitStyle
from prompt_toolkit.styles import merge_styles as _merge_prompt_toolkit_styles


_ipython = get_ipython()
_completion_style = _PromptToolkitStyle.from_dict(
    {
        "completion-menu": "fg:#e0def4 bg:#26233a",
        "completion-menu.completion": "fg:#e0def4 bg:#26233a",
        "completion-menu.completion.current": "fg:#191724 bg:#9ccfd8 noreverse",
        "completion-menu.meta.completion": "fg:#e0def4 bg:#403d52",
        "completion-menu.meta.completion.current": "fg:#191724 bg:#9ccfd8 noreverse",
        "completion-menu.multi-column-meta": "fg:#e0def4 bg:#403d52",
        "scrollbar": "fg:#e0def4 bg:#403d52",
    }
)
_ipython._style = _merge_prompt_toolkit_styles(
    [_ipython._style, _completion_style]
)

del _completion_style, _ipython
