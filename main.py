import os
import sys
import moderngl
import numpy as np
from PyQt5 import QtWidgets, QtCore
from PyQt5.QtOpenGL import QGLWidget
from PyQt5.QtWidgets import QLabel, QVBoxLayout, QWidget 
import time
import librosa

#####
##  QGLWidget, o contexto ModernGL 
##  responsavevel por carregar os shaders
#####
class ModernGLApp(QGLWidget):
    def __init__(self):
        super().__init__()
        self.setMouseTracking(True)
        self.start_time = time.time()

        # Iniciar um QTimer para atualizar a tela continuamente
        self.timer = QtCore.QTimer(self)
        self.timer.timeout.connect(self.update)  # O método `update` chama `paintGL` automaticamente
        self.timer.start(16)  # Aproximadamente 60 FPS (1000 ms / 16 ms)
        self.current_dir = os.path.dirname(os.path.abspath(__file__))

        # Configura a musica a ser analizada
        self.audio_path = os.path.join(self.current_dir, 'YoshuaEm_MM.mp3')
        self.y, self.sr = librosa.load(self.audio_path)
        self.n_bands = 6
        self.mel_spec = np.abs(librosa.stft(self.y))  # STFT para extrair frequências
        self.mel_spec = librosa.feature.melspectrogram(S=self.mel_spec, sr=self.sr, n_mels=self.n_bands)

    def get_band_energies(self):
        # Calcular a média de energia para cada banda ao longo do tempo
        energy_per_band = np.mean(self.mel_spec, axis=1)

        # Normalizar os valores de energia (para que fiquem entre 0 e 1)
        normalized_energy = energy_per_band / np.max(energy_per_band)
        return normalized_energy

    def initializeGL(self):
        # Criar o contexto ModernGL
        self.ctx = moderngl.create_context()

        # Carregar shaders
        current_dir = os.path.dirname(os.path.abspath(__file__))
        vertex_shader_path = os.path.join(current_dir, 'programs', 'vertex.glsl')
        fragment_shader_path = os.path.join(current_dir, 'programs', 'psy_fragment.glsl')

        vertex_shader = open(vertex_shader_path).read()
        fragment_shader = open(fragment_shader_path).read()

        # Criar o programa ModernGL
        self.program = self.ctx.program(
            vertex_shader=vertex_shader,
            fragment_shader=fragment_shader
        )

        # Definir a geometria manualmente para um quad fullscreen
        vertices = np.array([
            -1.9, -5.5, -10.0,  # canto inferior esquerdo
            1.0, 1.0, 1.0,   # canto inferior direito
            -1.9,  1.0, 1.0,  # canto superior esquerdo
            -1.9,  -1.0, 2.0,   # canto superior direito
        ], dtype='f4')

        self.vbo = self.ctx.buffer(vertices.tobytes())  # Criar o Vertex Buffer Object (VBO)
        self.vao = self.ctx.simple_vertex_array(self.program, self.vbo, 'in_vert')

    def resizeGL(self, w, h):
        self.ctx.viewport = (0, 0, w, h)

    def paintGL(self):
        # Limpar a tela
        self.ctx.clear(0.8, 0.1, 0.1)

        # Obter o tempo desde o início da aplicação
        current_time = time.time() - self.start_time

        # Passar valores uniformes para o shader
        self.program['time'].value = current_time
        self.program['u_resolution'].value = (self.width(), self.height())
        # Obter as energias normalizadas das bandas de frequência
        #band_energies = self.get_band_energies()

        # Passar as bandas de frequência como uniforms para o shader
        #for i, band in enumerate(band_energies):
            #print(i, band, sep="|")
       #     self.program[f'band_{i}'].value = band
        # Renderizar o quad fullscreen
        self.vao.render(moderngl.TRIANGLE_STRIP)

    def get_time(self):
        return time.time() - self.start_time  # Tempo em segundos desde o início

#####
##  Janela Principal, contendo o contexto ModernGL 
##
#####
class MainWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("ModernGL com PyQt5")
        self.setGeometry(100, 100, 800, 600)
        
        self.central_widget = QWidget()
        self.gl_widget = ModernGLApp()
        self.title = QLabel("QT + ModernGL")
        self.title.setMaximumHeight(20)
        
        self.layout = QVBoxLayout()
        self.layout.addWidget(self.title)
        self.layout.addWidget(self.gl_widget)
        self.setCentralWidget(self.central_widget)
        self.central_widget.setLayout(self.layout)

if __name__ == '__main__':
    app = QtWidgets.QApplication(sys.argv)
    window = MainWindow()
    window.show()
    app.exec_()
