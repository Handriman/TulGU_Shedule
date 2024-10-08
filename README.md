# Расписание ТулГУ

Приложение для просмотра расписания занятий в ТулГУ, оно позволяет легко и быстро узнать актуальное расписание.
Приложение создано на фреймворке Flutter и весь исходный код находится в открытом доступе

>[!important]
>Приложение создано обычным студентом и не является официальным! 

## Особенности

- Просмотр расписание без подключению к интернету
- Обновление расписание при наличии интернет соединения
- Красивый интерфейс без лишних элементов
- Приложение ___не собирает___ никакой телеметрии

## Использование

- После установки на устройство, при первом запуске появится диалоговое окно в котором есть поле для ввода номера группы.
- Номер группы следует вводить так же, как на официальном сайте, без пробелов и строчными буквами (если они есть).
- В дальнейшем изменить номер группы можно, нажав на значок шестерёнки в верхнем правом углу приложения.
- Так же возможно получать расписание для конкретных аудиторий вводя номер аудитории в формате "1-414", "Гл.-402"

## Установка

### Использование готового apk файла:

1. Скачайте apk файл из вкладки [releases](https://github.com/Handriman/TulGU_Shedule/releases)
2. Разрешите установку приложений из неизвестных источников в настройках вашего устройства
3. Установите приложение (Приложение проходит проверку на угрозы от Google на моем устройстве)
### Сборка из исходного кода

1. Установите [Dart sdk](https://dart.dev/get-dart)
2. Установите [Flutter sdk](https://docs.flutter.dev/get-started/install)
3. Установите [git](https://git-scm.com/downloads)
4. Клонируйте репозиторий командой
```
git clone https://github.com/Handriman/TulGU_Shedule.git
```
5. Перейдите в директорию проекта
```
cd TulGU_Schedule
```
6. Запустите команду сборки
```
flutter build apk
```
7. Собранный apk файл находится в "TulGU_Schedule/build/app/outputs/flutter-apk"

>[!note]
> Мной так же создан [телеграм бот](https://t.me/tulguschedule_bot) для просмотра расписания.
> Для обратной связи можно использовать команду в боте
