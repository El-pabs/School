import Navbar from 'react-bootstrap/Navbar';
import Container from 'react-bootstrap/Container';
import Nav from 'react-bootstrap/Nav';
import HeaderCartButton from './HeaderCartButton';
import { useNavigate } from 'react-router-dom'; // Import du hook useNavigate

function Header() {
    const navigate = useNavigate(); // Initialisation du hook useNavigate

    return (
        <Navbar expand="lg" className="bg-body-tertiary">
            <Container>
                <Navbar.Brand
                    onClick={() => navigate(-1)} // Revient à la page précédente
                    style={{ cursor: 'pointer' }} // Ajoute un curseur pour indiquer que c'est cliquable
                >
                    E-commerce
                </Navbar.Brand>
                <Navbar.Toggle aria-controls="basic-navbar-nav" />
                <Navbar.Collapse id="basic-navbar-nav">
                    <Nav className="ms-auto">
                        <HeaderCartButton />
                    </Nav>
                </Navbar.Collapse>
            </Container>
        </Navbar>
    );
}

export default Header;