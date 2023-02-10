.PHONY: format lint tests

all: format lint test

format:
	poetry run black .
	poetry run isort .

lint:
	poetry run mypy .
	poetry run black . --check
	poetry run isort . --check
	poetry run flake8 .

test: tests
tests:
	poetry run pytest -v -k 'not network'

tests-ci:
	poetry run pytest -v

clean:
	find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete

clean-tests:
	find . -name "*.yaml" -type f | xargs rm -f

upgrade-langchain:
	poetry add langchain@latest
	git commit -a -m "Upgrade to latest langchain"

release:
	test -z "$$(git status --porcelain)"
	poetry version patch
	git commit -am "Creating version v$$(poetry version -s)"
	git tag -a -m "Creating version v$$(poetry version -s)" "v$$(poetry version -s)"
	git push --follow-tags
	poetry publish --build --username $$PYPI_USERNAME --password $$PYPI_PASSWORD
