from recipe_scrapers import scrape_me
from googlesearch import search 
from flask import Flask
from flask import request
import json


#unpack JSON
app = Flask(__name__)

@app.route('/')
def index():
    return 'invalid call'

@app.route('/getRecipe', methods=['GET', 'POST'])
def getRecipe():
    data = request.data
    loaded_json = json.loads(data)
    body = loaded_json
    print("--API request received")
    
    query = body['ingredients'] + " recipe"
    url = ""
    for j in search(query, tld="co.in", num=1, stop=10, pause=2): 
        url = j
        print(url)
        break

    scraper =  scrape_me(url)
    print(scraper.ingredients())
    return json.dumps(scraper.ingredients())

    


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)