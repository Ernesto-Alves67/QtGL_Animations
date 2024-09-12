# Descrição de vextex.glsl e fragment.glsl
- O código shader.glsl é um vertex shader escrito na versão GLSL 330, e ele trabalha em conjunto com o fragment shader (o psy_fragment.glsl ) para renderizar gráficos. Vamos entender o papel de cada um deles e como eles se integram.
Vertex Shader (shader.glsl)

# Resumo:

**Vertex shader (shader.glsl):** Transforma as coordenadas dos vértices e define onde eles aparecem na tela. Ele pode também mover esses vértices no tempo, criando animações de movimento.
    
**Fragment shader (psy_fragment.glsl):** Define a cor de cada pixel baseado em coordenadas de tela, distância, paletas de cores e tempo. Ele cria padrões visuais animados e dinâmicos para os pixels que compõem os triângulos renderizados pelos vértices.
    Portanto, em conjunto, esses dois shaders renderizam uma imagem animada na tela: o vertex shader posiciona os vértices no espaço, e o fragment shader aplica efeitos visuais dinâmicos a cada pixel para gerar a aparência final.

O vertex shader processa os vértices de um objeto gráfico. Seu objetivo é transformar as coordenadas dos vértices (pontos) de um objeto de um espaço local (como o espaço do modelo) para o espaço de tela. Ele também pode manipular ou transformar as posições dos vértices para efeitos animados ou outras operações.

## Vextex Shader (vertex.glsl):

- Entrada in_vert: Esse é o atributo de entrada que fornece as coordenadas dos vértices do objeto. A variável in_vert contém as coordenadas (em 2D) dos vértices que serão renderizados.

- Uniform time: Esta variável uniform é um valor que pode ser passado para o shader a partir do programa principal (por exemplo, OpenGL ou outro sistema gráfico). O time pode ser usado para criar animações ou efeitos dinâmicos.

- Transformação de posição: O código que você forneceu transforma as coordenadas do vértice e define a posição final de cada vértice através da variável gl_Position. Neste caso, ele usa as coordenadas 2D diretamente de in_vert e as coloca no espaço 3D (vec4(position, 0.0, 1.0)), onde 0.0 é o valor z e 1.0 é o fator homogêneo para as coordenadas de projeção.

- Movimentação ao longo do tempo (comentado): Há uma ideia comentada no código, onde a posição do vértice poderia se mover ao longo do tempo. Você poderia animar a posição do objeto alterando as coordenadas dos vértices com base no time (o que parece ser o objetivo inicial). Isso permitiria que os objetos no espaço se movam de acordo com o tempo.

**Em resumo, este vertex shader é muito simples** e basicamente passa as coordenadas dos vértices diretamente para o sistema de renderização, sem muita manipulação ou transformação além de colocar as coordenadas no espaço de tela.

## Fragment Shader (psy_fragment.glsl)

O fragment shader é responsável por definir a cor de cada pixel (ou fragmento) na tela. Ele trabalha em conjunto com o vertex shader. Depois que o vertex shader processa os vértices e os coloca na tela, o fragment shader é chamado para cada pixel coberto pela forma renderizada, e ele decide a cor daquele pixel.

O fragment shader anterior (psy_fragment.glsl) faz uma série de operações para gerar efeitos visuais, incluindo:

- Cálculos de distâncias para criar um padrão visual interessante.
- Uso de paletas de cores para animar as cores de acordo com o tempo.
- Loops para gerar distorções e efeitos que mudam ao longo do tempo. 
    Aplicação de transformações visuais sobre as coordenadas dos fragmentos para criar uma animação visual.

Esse fragment shader utiliza as coordenadas da tela (gl_FragCoord) e informações como a resolução (iResolution) e o tempo (iTime) para criar um efeito visual dinâmico e animado.
Interação entre o Vertex Shader e o Fragment Shader

## Como os dois shaders funcionam juntos:

- O vertex shader (shader.glsl) processa as posições dos vértices, transformando-os para o espaço de tela. Ele basicamente diz onde cada ponto (vértice) do objeto está na tela.
- Depois que os vértices são processados, o sistema rasteriza os triângulos formados por esses vértices, ou seja, ele preenche os triângulos e calcula quais pixels na tela são cobertos pelos triângulos.
- Para cada pixel coberto, o fragment shader (psy_fragment.glsl) é chamado para determinar a cor do pixel. O fragment shader então usa as coordenadas de tela (gl_FragCoord), resolução, e tempo para criar efeitos visuais, aplicando distorções e paletas de cores animadas.

