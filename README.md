# API-interface-photo-storage
Backend highload application for sharing photo dataset

## 1. Задача:

Разработать и реализовать программный интерфейс (API), соответствующим следующим требованиям:
- Должен позволять загружать изображения по нескольку файлов за операцию (минимально 100)
- Должен предоставлять результат загрузки фото. Результат - ссылка на фото, которая будет доступна через интерфейс
- Соответствовать лучшим практикам REST (В серверном приложении должны быть стандартные REST маршруты следующего вида:
POST - принимает массив изображений в виде стрима
    http://domain-name/upload
GET - возвращает фото по ссылке (или превью фото)
    http://domain-name/get
).

## 2. Стек технологий:

Бэкенд - серверное приложение на Python, фреймворк: Flask, SqlAlchemy
Фронтенд - клиентское приложение на JS HTML, кроссплатформенное мобильное приложение на Flutter (Dart) для Android/Ios с поддержкой Web-версии

## 3. Интерфейс

Классическое REST API, загруженное на сервер 185.43.6.193:
http://185.43.6.193:5000/ [POST] - загрузка файла на сервер, в запросе присутствует медиафайл под тегом 'file'
http://185.43.6.193:5000/display [GET] - запрос вида id=varchar36, для получения изображения с заданным названием или уникальным ID
http://185.43.6.193:5000/get_value [GET] - запрос для получения данных из таблицы для всех изображений (id, название)


## 4. БД

БД должна хранить UID загруженного фото и ссылку на фото. Необходимо создать БД, предусмотреть соответствующие столбцы
Необходимо реализовать модуль "Репозиторий" для инкапсуляции логики взаимодействия с БД. Наверное, лучше чистым SQL, для пущего быстродействия.
Тип БД - что-то легковесное, in memory DB, SQLite и т.д.

## 5. Установка и запуск:

Для Ubuntu 20.04:

### Если не установлен nginx:
Install nginx:
```
sudo apt-get update
sudo apt-get install nginx
```
### Если не установлен Python
Install Python Environment:
```
sudo apt install python3-pip python3-dev build-essential libssl-dev libffi-dev python3-setuptools
```
Setup Python virtual environment:
```
pip3 install virtualenv
mkdir ~/projectfolder
cd ~/projectfolder
python3 -m virtualenv projectenv
source projectenv/bin/activate
```
### Установка Flask
Setup Flask:
```
pip install wheel
pip install uwsgi flask
```
Помещаем исходный код из папки /app во flask environment, т.е. в папку ~/projectfolder/projectenv/bin
Загружаем библиотеку SqlAlchemy:
```
pip3 install flask_sqlalchemy
```
Запускаем  приложение:
```
python main.py
```
