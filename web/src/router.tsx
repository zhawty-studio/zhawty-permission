import { createHashRouter } from "react-router-dom";
import { Layout } from "./layout";

export const Router = createHashRouter([
  {
    path: '/',
    element: <Layout />
  }
])