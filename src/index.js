import elmWebComponents from '@teamthread/elm-web-components';
import { Elm } from './Main.elm';

elmWebComponents.configure('0.19')

elmWebComponents.register('much-selector', Elm.Main, {useShadowDom: true})
