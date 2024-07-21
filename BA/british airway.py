!pip install beautifulsoup4 requests
import requests
import pandas as pd
from bs4 import BeautifulSoup

num_page = 383
reviews = []
for i in range(1, num_page +1):
    url = f'https://www.airlinequality.com/airline-reviews/british-airways/page/{i}/'
    response = requests.get(url)
    response = response.content # gets all content in "inspect element"
    soup = BeautifulSoup(response, 'html.parser') #makes content in inspect element more clear


    #find all article that has all reviews on a page
    article = soup.find('article')
    user_reviews = article.find_all('article', itemprop='review')
    
    

    for review in user_reviews:
        
        title_tag = review.find('h2', class_='text_header')
        title = title_tag.text.strip().strip('“”') if title_tag else 'N/A'
        
        rate_tag = review.find('span', itemprop='ratingValue')
        rate = rate_tag.text if rate_tag else 'N/A'
        
        name_tag = review.find('span', itemprop='name')
        name = name_tag.text if name_tag else 'N/A' 
        
        date_posted_tag = review.find('time', itemprop='datePublished')
        date_posted = date_posted_tag.text if date_posted_tag else 'N/A' 
        
        verification_tag = review.find('strong')
        verification = verification_tag.text if verification_tag else 'N/A'
        
        review_text_tag = review.find('div', class_='text_content')
        try:
            review_text = review_text_tag.text.split('|', 1)[1].strip() if review_text_tag else 'N/A'
        except IndexError:
            review_text = 'N/A'
        
        table = review.find('table', class_='review-ratings')
        #if a table is present
        if table:
            aircraft = table.find('td', text='Aircraft').find_next_sibling('td').text if table.find('td', text='Aircraft') else 'N/A'
            travel_purpose = table.find('td', text='Type Of Traveller').find_next_sibling('td').text if table.find('td', text='Type Of Traveller') else 'N/A'
            seat_type = table.find('td', text='Seat Type').find_next_sibling('td').text if table.find('td', text='Seat Type') else 'N/A'
            route = table.find('td', text='Route').find_next_sibling('td').text if table.find('td', text='Route') else 'N/A'
            date_flown = table.find('td', text='Date Flown').find_next_sibling('td').text if table.find('td', text='Date Flown') else 'N/A'
            seat_type = table.find('td', text='Seat Type').find_next_sibling('td').text if table.find('td', text='Seat Type') else 'N/A'
            seat_comfort_rating = len(table.find('td', text='Seat Comfort').find_next_sibling('td').find_all('span', class_='star fill')) if table.find('td', text='Seat Comfort') else 'N/A'
            cabin_service_rating = len(table.find('td', text='Cabin Staff Service').find_next_sibling('td').find_all('span', class_='star fill')) if table.find('td', text='Cabin Staff Service') else 'N/A'
            meal_rating = len(table.find('td', text='Food & Beverages').find_next_sibling('td').find_all('span', class_='star fill')) if table.find('td', text='Food & Beverages') else 'N/A'
            ground_service_rating = len(table.find('td', text='Ground Service').find_next_sibling('td').find_all('span', class_='star fill')) if table.find('td', text='Ground Service') else 'N/A'
            money_value_rating = len(table.find('td', text='Value For Money').find_next_sibling('td').find_all('span', class_='star fill')) if table.find('td', text='Value For Money') else 'N/A'
            inflight_entertainment_rating = len(table.find('td', text='Inflight Entertainment').find_next_sibling('td').find_all('span', class_='star fill')) if table.find('td', text='Inflight Entertainment') else 'N/A'
            wifi_rating = len(table.find('td', text='Wifi & Connectivity').find_next_sibling('td').find_all('span', class_='star fill')) if table.find('td', text='Wifi & Connectivity') else 'N/A'
            recommended = table.find('td', text='Recommended').find_next_sibling('td').text if table.find('td', text='Recommended') else 'N/A'
        
        
        
        
        reviews.append([name, rate, date_posted, title, verification, review_text, aircraft, seat_type, 
                    travel_purpose, route, date_flown, seat_comfort_rating, cabin_service_rating, 
                    meal_rating, ground_service_rating, 
                    money_value_rating, inflight_entertainment_rating, wifi_rating, recommended])
    print(f'Page {i} is done')

df = pd.DataFrame(reviews, columns=['name', 'rate', 'date_posted', 'title', 'verification', 'review_text', 
                                    'aircraft', 'seat_type', 'travel_purpose', 'route', 'date_flown', 
                                    'seat_comfort_rating', 'cabin_service_rating', 'meal_rating', 
                                    'ground_service_rating', 'money_value_rating', 'inflight_entertainment_rating', 
                                    'wifi_rating', 'recommended'])
df.to_csv('british_airways_reviews.csv', index=False)
print('CSV saved successfully.')    

    