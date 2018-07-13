# escape=`

FROM python:3.6.6-windowsservercore-1709

RUN pip install pipenv

ADD Pipfile Pipfile.lock C:/src/

# RUN set size=0 && `
#     for /f %i in ("wrap") do set size=%~zi && `
#     echo %size%

ENV PIPENV_PIPFILE=C:\\src\\Pipfile `
    WORKON_HOME=C:\\venv

RUN if ( (get-childitem C:\\src\\Pipfile.lock).length -eq 0 ) `
    { `
      pipenv lock`
    }; `
    pipenv install; `
    rm -recurse C:\\src

CMD cd c:\\src; `
    pipenv run pyinstaller just.spec