import styled from 'styled-components';
import { ThemeType } from '@/styles/themes/types/theme';

declare module 'styled-components'{
  export interface DefaultTheme extends ThemeType{}
}