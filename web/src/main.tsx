import React from 'react';
import ReactDOM from 'react-dom/client';
import { VisibilityProvider } from '@/providers/VisibilityProvider';
import { RouterProvider } from 'react-router-dom';
import { Router } from '@/router';
import { GlobalStyles } from '@/styles/global';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <VisibilityProvider>
      <RouterProvider router={Router} />

      <GlobalStyles />
    </VisibilityProvider>
  </React.StrictMode>,
);
