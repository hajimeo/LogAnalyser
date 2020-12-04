# TEST
_PWD="xxxx"
curl -sf -D/dev/stderr -o/dev/null -b ./cookie.txt -c ./cookie.txt "http://localhost:8999/login"
_XSRF="$(grep -w '_xsrf' cookie.txt | awk '{print $7}')"
curl -sf -D/dev/stderr -o/dev/null -b ./cookie.txt -c ./cookie.txt 'http://localhost:8999/login?next=%2F' \
  --data-urlencode "_xsrf=${_XSRF}" \
  --data-urlencode "password=${_PWD}"  
curl -sf -D/dev/stderr -o/dev/null -b ./cookie.txt -c ./cookie.txt "http://localhost:8999/api/contents/Untitled.ipynb" -H "Content-Type: application/json" | python -m json.tool
