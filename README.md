ExpirationList
==============

Food management app

This app displays an oldest-first list of food items in a user's refrigerator to help its users better manage their food resources (and avoid having to clean out moldy food).

The purpose of this app is to allow its users to keep a convenient index of the food items they've purchased. It includes the age of an item (since the day of purchase), and allows for users to sync their food lists with other users' food lists (for example if they live in the same home). Users can add items manually or take a picture of a receipt and add all of its contents at once using Google's Tesseract OCR engine compiled for iOS (https://github.com/gali8/Tesseract-OCR-iOS).

Special thanks to Daniele Galiotto (http://www.g8production.com/)

This project is on hiatus for a little while until I learn how to write my own OCR--Google's Tesseract is not a perfect tool, and it's uncomfortable having such a huge element of my project be out of my control.

Goals:
--------------
- Add perspective transform to image capture to correct for skew
- Never have user take picture, instead grab frames from viewfinder in image picker controller
- Automatically escape when complete
- Add field for expected expiration date