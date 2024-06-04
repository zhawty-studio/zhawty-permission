import React, { Context, SetStateAction, createContext, useContext, useState } from "react";
import { ThemeProvider } from "styled-components";

import { DarkTheme } from "@/styles/themes/dark";
import { LightTheme } from "@/styles/themes/light";

const ThemeCtx = createContext<ThemeHookProps | null>(null)

interface ThemeHookProps {
  theme: 'dark' | 'light';
  setTheme: React.Dispatch<SetStateAction<'dark' | 'light'>>
}

export const AppThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [theme, setTheme] = useState<'dark' | 'light'>('dark');

  return (
    <ThemeCtx.Provider value={{ theme, setTheme }}>
      <ThemeProvider theme={theme === 'dark' ? DarkTheme : LightTheme}>
        {children}
      </ThemeProvider>
    </ThemeCtx.Provider>
  )
}

export const useTheme = () => useContext<ThemeHookProps>(ThemeCtx as Context<ThemeHookProps>)
