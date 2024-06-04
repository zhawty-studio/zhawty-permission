import styled, { css } from 'styled-components';

import {
    ReactSVG
} from 'react-svg';

export const IconStyled = styled(ReactSVG)<any>`
    height: 100;

    display: inline-flex;
    align-items: center;
    justify-content: center;

    padding: ${props => props.padding + 'vh'};

    background-position: center;
    background-repeat: no-repeat;

    span {
        width: 100%;
        height: 100%;

        display: inline-flex;
        align-items: center;
        justify-content: center;
    };

    svg {
        width: ${props => props.size+'vw'};
        height: 100%;

        fill: black;
    };

    path {
        fill: ${props => props.color};

        fill-opacity: 1;

        ${props => props.isonpage && css`
          fill-opacity: 1;
        `}
    };

    svg:hover {
        transition: all ease 0.1s;

        path {
            fill: ${props => props.hovercolor};
        };
    };
`;
