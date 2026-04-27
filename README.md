# PeroAI - Your Smart Text Assistant

[Українська версія нижче](#peroai---твій-розумний-помічник-для-тексту)

**PeroAI** is a lightweight and powerful tool built with AutoHotkey v2 that leverages cutting-edge AI models (Groq Cloud and Google Gemini) to provide instant text correction, translation, and analysis directly in any Windows application.

> **Note:** This project was developed with the assistance of Artificial Intelligence.

## ✨ Features

- **Instant Correction (Win+Q)**: Fix grammar, spelling, and punctuation in one click.
- **AI Prompt (Win+A)**: Open a dedicated window for custom AI queries about the selected text. Ask for explanations, summaries, or specific rewrites.
- **Multi-Provider Support**:
  - **Groq Cloud**: Ultra-fast models like Llama 4, Llama 3.3, GPT-OSS, Qwen 3.
  - **Google Gemini**: Stable models like Gemini 2.5 Flash and Flash Lite.
- **Flexible Work Modes**:
  - `Confirm`: Review the AI result before replacing.
  - `Auto`: Automatically replace the selected text with the AI's result.
  - `Clipboard`: Copy the result to the clipboard without changing the source text.
- **Quick Buttons**: Customizable commands for frequent tasks (Translate, Explain, Shorten, etc.).
- **Multilingual**: Full support for Ukrainian and English.

## 🚀 Getting Started

1.  Install [AutoHotkey v2](https://www.autohotkey.com/).
2.  Download the [project files](https://github.com/Haytak/PeroAI/releases) and extract them to a separate folder.
3. Run `PeroAI.ahk`.
4.  On the first run, the app will create configuration files automatically.
5.  Press `Win+S` to open settings.
6.  Enter your API keys for Groq or Gemini (guides are linked in the settings).
7.  Select any text and press `Win+Q` for correction or `Win+A` for a custom prompt!

---

# PeroAI - Твій розумний помічник для тексту

**PeroAI** — це легкий та потужний інструмент на базі AutoHotkey v2, який використовує передові моделі штучного інтелекту (Groq Cloud та Google Gemini) для миттєвої корекції, перекладу та аналізу тексту прямо у будь-якому додатку Windows.

> **Примітка:** Цей проект було створено за допомогою штучного інтелекту.

## ✨ Можливості

- **Миттєва корекція (Win+Q)**: Виправлення граматики, пунктуації та стилістики одним натисканням.
- **AI Промпт (Win+A)**: Окреме вікно для довільних запитів до ШІ щодо виділеного тексту. Ви можете просити пояснити термін, зробити резюме або перефразувати текст.
- **Підтримка декількох провайдерів**:
  - **Groq Cloud**: Надшвидкі моделі Llama 4, Llama 3.3, GPT-OSS, Qwen 3.
  - **Google Gemini**: Стабільні моделі Gemini 2.5 Flash та Flash Lite.
- **Гнучкі режими роботи**:
  - `Confirm`: Відображення результату перед заміною.
  - `Auto`: Автоматична заміна тексту.
  - `Clipboard`: Тільки копіювання результату в буфер обміну.
- **Швидкі кнопки**: Налаштовувані команди для часто вживаних запитів (Переклад, Пояснення тощо).
- **Багатомовність**: Повна підтримка української та англійської мов.

## 🚀 Як почати

1.  Встановіть [AutoHotkey v2](https://www.autohotkey.com/).
2.  Завантажте [файли проекту](https://github.com/Haytak/PeroAI/releases) та розпакуйте у окрему папку.
3.  Запустіть `PeroAI.ahk`.
4.  При першому запуску програма створить файли конфігурації автоматично.
5.  Натисніть `Win+S`, щоб відкрити налаштування.
6.  Введіть ваші API ключі для Groq або Gemini (посилання на інструкції є в самому додатку).
7.  Виділіть будь-який текст і натисніть `Win+Q` для корекції або `Win+A` для довільного запиту!

## ⚙️ Налаштування

Файли конфігурації (створюються автоматично):
- `config.ini`: Зберігає ваші API ключі (не передавайте цей файл нікому!).
- `settings.ini`: Зберігає налаштування мови, режимів, гарячих клавіш та кнопок.

## 🛠 Технології

- **AutoHotkey v2**: Для автоматизації Windows та GUI.
- **Neutron.ahk**: Фреймворк для створення сучасних HTML/CSS інтерфейсів.
- **Groq API / Gemini API**: Потужний ШІ бекенд.

## 📄 Ліцензія

Цей проект поширюється під ліцензією MIT. Ви можете вільно використовувати та модифікувати його.
