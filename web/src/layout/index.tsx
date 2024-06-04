import { Container } from "./styles";
import { Outlet } from 'react-router-dom'
export function Layout() {
  return (
    <Container>
      <Outlet />
    </Container>
  )
}