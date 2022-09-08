import os
import glob
from os import path
from os.path import exists as file_exists


def press_any():
    print("\nPressione qualquer tecla para continuar\n")
    input("")


def get_fichas(fichas_path_2):
    root = os.getcwd()
    files = []
    os.chdir(fichas_path_2)
    for file in glob.glob("*.txt"):
        files.append(file)
    os.chdir(root)
    return files


fichas_path = ""
fichas = []
nome_arquivo_caminho = "path.pauloguina"
try:
    if file_exists(nome_arquivo_caminho):
        f = open(nome_arquivo_caminho, "r")
        fichas_path = f.readline()
        f.close()
        if path.exists(fichas_path):
            fichas = get_fichas(fichas_path)
            if fichas:
                print("Pegando caminho padrão:" + fichas_path)
            else:
                print("Pasta não contem fichas, precione qualquer tecla e adicione fichas em "+"\""+fichas_path+"\"")
                input("")
                exit()
        else:
            print("\nCaminho não encontrado, precione qualquer tecla e abra novamente o programa para informar um "
                  "novo caminho\n")
            input()
            os.remove(nome_arquivo_caminho)
            exit()
    else:
        fichas_path = str(input("Digite o caminho da pasta com as fichas:"))
        if path.exists(fichas_path):
            fichas = get_fichas(fichas_path)
            if fichas:
                f = open(nome_arquivo_caminho, "w")
                f.write(fichas_path)
                f.close()
            else:
                print("Pasta não contem fichas, precione qualquer tecla e adicione fichas em "+"\""+fichas_path+"\"")
                input("")
                exit()
        else:
            print("\nCaminho:" + "\"" + fichas_path + "\" não encontrado")
            press_any()
            exit()
except OSError:
    print("\nErro ao tentar usar ou modificar o caminho da pasta")
    press_any()
    exit()


stats = [-1, -1, -1, -1, -1]
aux = [-1, -1, -1, -1, -1]
transformacoes = [[1, 1, 1, 1, 1]]
transformacoes_nomes = ["Base"]

for i in range(10000):
    transformacoes.append([0, 0, 0, 0, 0])
    transformacoes_nomes.append([])

escolha = -1
while escolha != 0:
    stat_index = 0
    file_index = 0
    transformation_index = 1
    os.system('cls')
    print("Escolha a ficha")
    print("\n[0]Sair do programa")
    for i in fichas:
        print("[" + str(file_index + 1) + "]" + str(i).split("\\")[-1])
        file_index += 1

    escolha = file_index + 1
    while escolha > file_index or escolha < 0:
        try:
            escolha = int(input())
            if escolha == 0:
                exit()
        except ValueError:
            pass

    os.system('cls')
    f = open(fichas_path + "\\" + fichas[escolha - 1], "r")
    for x in f:
        if "Nome" in x:
            print(x)
        if "*" in x:
            stat = x.split(":")
            stats[stat_index] = int(stat[1])
            aux[stat_index] = int(stat[1])
            stat_index += 1
        if "@" in x:
            multiplier = x.split("[")[1].split("\n")[0].split("]")[0].split(",")
            for i in range(5):
                transformacoes[transformation_index][i] = int(multiplier[i])
            transformacoes_nomes[transformation_index] = x.split(":")[0].split("@")[1]
            transformation_index += 1
    f.close()

    for i in range(transformation_index):
        for j in range(5):
            aux[j] = stats[j] * transformacoes[i][j]

        forca = aux[0]
        destreza = aux[1]
        resistencia = aux[2]
        inteligencia = aux[3]
        espirito = aux[4]

        print("---------------------------------------------------------------")
        power_level = str((5 * forca) + (2 * destreza) + (2 * resistencia) + (2 * inteligencia) + (5 * espirito))
        print(str(transformacoes_nomes[i]) + (":(Poder de luta " + power_level + ")"))
        print("Vida:" + str(resistencia * 50))
        print("Ki:" + str(espirito * 50))
        print("\nForça:" + str(forca))
        print("Destreza:" + str(destreza))
        print("Resistencia:" + str(resistencia))
        print("Inteligencia:" + str(inteligencia))
        print("Espirito:" + str(espirito))

    press_any()
