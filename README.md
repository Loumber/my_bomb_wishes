# MyBombWishes

Telegram Mini App на Flutter для ведения списка желаний и обмена идеями подарков с друзьями.

Открыть приложение: [@MyBombWishesBot](https://t.me/MyBombWishesBot)

## О проекте

MyBombWishes помогает пользователям собирать желания в одном месте, добавлять к ним описание, ссылку, цену и изображение, а также смотреть профили друзей и их списки. Приложение запускается внутри Telegram как Mini App и использует данные Telegram Web App для авторизации пользователя.

## Возможности

- Авторизация через Telegram Mini App.
- Личный профиль пользователя.
- Создание, редактирование и удаление желаний.
- Добавление изображения, ссылки, описания и цены к желанию.
- Отображение желаний в masonry-grid.
- Просмотр друзей, подписчиков и подписок.
- Поиск пользователей и переход в чужие профили.
- Поддержка запуска вне Telegram через fake Telegram service для локальной разработки.

## Стек

- Flutter Web / Dart.
- `telegram_web_app` для интеграции с Telegram Mini App.
- Supabase для авторизации, профилей, желаний и подписок.
- Firebase Hosting для публикации web-сборки.
- `get_it` для dependency injection.
- `rxdart` для реактивных состояний.
- `flutter_staggered_grid_view` для сетки желаний.
- `image_picker_web` для загрузки изображений в web.

## Структура проекта

```text
lib/
  common/          # инициализация приложения, DI, логирование
  data/            # реализации репозиториев и Telegram service
  domain/          # сущности, контракты репозиториев, use cases
  presentation/    # страницы, view models и UI-виджеты
web/               # web entrypoint и manifest
firebase.json      # конфигурация Firebase Hosting
```

## Локальный запуск

Требования:

- Flutter SDK с поддержкой web.
- Dart SDK `^3.7.2`.
- Настроенный доступ к Supabase-проекту.

Установите зависимости:

```bash
flutter pub get
```

Запустите приложение в браузере:

```bash
flutter run -d chrome
```

Если Flutter сообщает об отсутствующем `.env`, создайте файл `.env` в корне проекта. Сейчас приложение загружает этот файл на старте и подключает его как asset.

## Сборка Web

```bash
flutter build web
```

Готовая сборка появится в `build/web`.

## Деплой

Проект настроен для деплоя через Firebase Hosting. В `firebase.json` публичная директория указывает на `build/web`, а все маршруты переписываются на `index.html`, чтобы Flutter Web корректно работал как SPA.

```bash
flutter build web
firebase deploy
```

## Telegram Mini App

Приложение рассчитано на запуск внутри Telegram через бота [@MyBombWishesBot](https://t.me/MyBombWishesBot). При старте Mini App вызывает Telegram Web App API, сообщает Telegram, что интерфейс готов, отключает вертикальные свайпы и разворачивает приложение на доступную высоту.

Для локальной разработки вне Telegram используется fallback-сервис, поэтому UI можно запускать и проверять в браузере.

## Разработка

Перед отправкой изменений проверьте форматирование и статический анализ:

```bash
dart format .
flutter analyze
```

Запуск тестов:

```bash
flutter test
```
