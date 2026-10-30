# Curva de crecimiento de von Bertalanffy

Aplicación interactiva para generar y personalizar curvas de crecimiento de von Bertalanffy y exportarlas en formatos vectoriales.

## Uso

1. Ajusta los parámetros del modelo: $\(L_\infty\)$, $\(K\)$ y $\(t_0\)$.
2. Personaliza la apariencia de la figura: colores, líneas, tipografía, ejes y etiquetas.
3. Define las dimensiones de exportación y el nombre del archivo.
4. Descarga la figura en **SVG** o **PDF**.

## Formatos de exportación

- **SVG:** recomendado para editar los elementos de la figura individualmente.
- **PDF:** recomendado para incorporar la figura en manuscritos y documentos científicos.

Ambos formatos conservan los elementos gráficos como vectores, por lo que pueden ampliarse sin perder nitidez.

## Parámetros del modelo

$$
L_t=L_{\infty} \left(1-e^{K(t-t_0)} \right)
$$

- $\(L_\infty\)$: longitud asintótica estimada.
- $\(K\)$: coeficiente de crecimiento.
- $\(t_0\)$: edad teórica a la que la longitud es cero.

Los valores iniciales son ilustrativos. Reemplázalos por los parámetros correspondientes a la especie o población que deseas representar.

## Importante

La aplicación genera una curva teórica a partir de los parámetros ingresados; no estima los parámetros a partir de datos de talla y edad. Revisa las unidades de longitud y edad antes de exportar la figura.
