from bs4 import BeautifulSoup
import requests

my_page = "Polling Units – INEC Nigeria.html"
soup = BeautifulSoup(open(r"C:\Users\SunnyfromOctaveAnaly\Desktop\Polling Units – INEC Nigeria.html"), 'lxml')
soup = soup.find('div', class_ ="form-group")
items = soup.select('option[value]')
values = [item.get('value') for item in items]
x = [str(item) for item in values]
print(x)
