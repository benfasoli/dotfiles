# increase maximum number of files that can be open concurrently
ulimit -S -n 2048

# disable parallel limits in MacOS for python multiprocessing
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# use virtual environments in project
export PIP_REQUIRE_VIRTUALENV=true
export PIPENV_VENV_IN_PROJECT=1
export POETRY_VIRTUALENVS_IN_PROJECT=1

# avoid creating .pyc files during development
export PYTHONDONTWRITEBYTECODE=1

# disable autocd
unsetopt AUTO_CD

# preempt PATH with brew installs
eval "$(/opt/homebrew/bin/brew shellenv)"
export C_INCLUDE_PATH="/opt/homebrew/opt/python3/Frameworks/Python.framework/Headers"

# preempt PATH with user-scoped installs
export PATH="$HOME/.local/bin:$PATH"

# source uv
. "$HOME/.cargo/env"
