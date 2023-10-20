import 'react-i18next'

// import all namespaces (for the default language, only)
import { en } from './i18n-init'

declare module 'react-i18next' {
  export interface Resources {
    translation: typeof en
  }
}
