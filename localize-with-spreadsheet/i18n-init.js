import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import * as RNLocalize from 'react-native-localize'
import en from './en.json'
import fr from './fr.json'

// Список локализаций, ключи языков должны подходить для использования в i18n
const translations = {
  en,
  fr,
}

// Язык по-умолчанию, будет применяться для языков отсутствующих в локализации
const fallback = { languageTag: 'en', isRTL: false }

// Выбор файла локализации исходя из языка системы
// при отсутствии такого выбирается язык по-умолчанию.
// Если нет необходимости автоматически определять язык системы можно 
// выбирать languageTag по-другому, например селектором + AsyncStorage либо захардкодить
const { languageTag } =
  RNLocalize.findBestAvailableLanguage(Object.keys(translations)) || fallback

// Инициализация I18N
i18n.use(initReactI18next).init({
  resources: {
    [languageTag]: {
      translation: translations[languageTag],
    },
  },
  lng: languageTag,
})

export { i18n, en, fr }
