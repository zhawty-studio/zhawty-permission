import { isEnvBrowser } from "@/utils/misc";
import { createGlobalStyle, css } from "styled-components";

export const GlobalStyles = createGlobalStyle`
  *{
    margin: 0;
    padding: 0;

    box-sizing: border-box;

    font-family: 'Poppins';
  }

  body{
    ${isEnvBrowser() && css`
      background: url("https://media.discordapp.net/attachments/829521015402528798/1187456348632391799/image.png?ex=6596f3e7&is=65847ee7&hm=45a88a8f355906d6fd377a0d0ac01130bce33bc33b35ea0c8139d3595f1abaca&=&format=webp&quality=lossless&width=1202&height=676");
      background-size: 100% !important;
    `}
  }
  `;
