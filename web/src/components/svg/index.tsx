import * as S from './styles';

interface SvgProps extends React.SVGAttributes<SVGAElement> {
    file: string;

    color: string | undefined;
    hovercolor?: string | number;

    size?: number;

    padding?: number;

    onpage?: boolean;
}

export function Svg(props: SvgProps) {
	return (
        <S.IconStyled
            color={props.color}
            hovercolor={props.hovercolor}
            size={props.size}
            padding={props.padding}
            src= {`${props.file}`}
            wrapper="span"
            isonpage={props.onpage}
        />
	);
}
