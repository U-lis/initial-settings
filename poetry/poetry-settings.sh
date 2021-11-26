clear
#if [ $1 = 1 ]; then
#  echo "You already have poetry. Exiting..."
#  return
#fi

echo "Installing poetry..."
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
