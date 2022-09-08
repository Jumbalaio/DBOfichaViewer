import glob
import sys
import os
from os import path
from os.path import exists as file_exists


def press_any(frase):
    print("\n"+frase+"\n")
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

if file_exists(nome_arquivo_caminho):
    f = open(nome_arquivo_caminho, "r")
    fichas_path = f.readline()
    f.close()
    if path.exists(fichas_path):
        fichas = get_fichas(fichas_path)
        if fichas:
            print("Pegando caminho padrão:" + fichas_path)
        else:
            print("Pasta não contem fichas, precione qualquer tecla e adicione fichas em " + "\"" + fichas_path + "\"")
            input("")
            sys.exit()
    else:
        print("\nCaminho não encontrado, precione qualquer tecla e abra novamente o programa para informar um "
              "novo caminho\n")
        input()
        os.remove(nome_arquivo_caminho)
        sys.exit()
else:
    fichas_path = str(input("Digite o caminho da pasta com as fichas:"))
    if path.exists(fichas_path):
        fichas = get_fichas(fichas_path)
        if fichas:
            f = open(nome_arquivo_caminho, "w")
            f.write(fichas_path)
            f.close()
        else:
            print("Pasta não contem fichas, precione qualquer tecla e adicione fichas em " + "\"" + fichas_path + "\"")
            input("")
            sys.exit()
    else:
        press_any("Caminho:" + "\"" + fichas_path + "\" não encontrado")
        sys.exit()

stats = [-1, -1, -1, -1, -1]
aux = [-1, -1, -1, -1, -1]
transformacoes = [[1, 1, 1, 1, 1]]
transformacoes_nomes = ["Base"]
stats_nomes = ["Força", "Destreza", "Resistencia", "Inteligencia", "Espirito"]

while True:
    stat_index = 0
    file_index = 0
    transformation_index = 1
    os.system('cls')
    print("Escolha a ficha\n[0]Sair do programa")

    for i in fichas:
        print("[" + str(file_index + 1) + "]" + str(i).split("\\")[-1])
        file_index += 1

    escolha = file_index + 1
    while escolha > file_index or escolha < 0:
        try:
            escolha = int(input())
        except ValueError:
            pass

    if escolha == 0:
        break

    nome = "Não encontrado"
    os.system('cls')
    f = open(fichas_path + "\\" + fichas[escolha - 1], "r")
    for x in f:
        if "Nome" in x:
            nome = x
        if "*" in x:
            stat = x.split(":")[1].strip()
            stats[stat_index] = int(stat)
            aux[stat_index] = int(stat)
            stat_index += 1
        if "@" in x:
            multiplier = x.split("[")[1].split("\n")[0].split("]")[0].split(",")
            transformacoes.append([-1, -1, -1, -1, -1])
            transformacoes_nomes.append([])
            for i in range(5):
                transformacoes[transformation_index][i] = int(multiplier[i].strip())
            transformacoes_nomes[transformation_index] = x.split(":")[0].split("@")[1].strip()
            transformation_index += 1
    f.close()
    print(nome)
    for i in range(transformation_index):
        for j in range(5):
            aux[j] = stats[j] * transformacoes[i][j]

        for j in range(60):
            print("-", end="")
        power_level = str((5 * aux[0]) + (2 * aux[1]) + (2 * aux[2]) + (2 * aux[3]) + (5 * aux[4]))

        print("\n" + str(transformacoes_nomes[i]) + ":(Poder de luta " + power_level + ")")
        print("Vida:" + str(aux[2] * 50))
        print("Ki:" + str(aux[4] * 50) + "\n")
        for j in range(5):
            print(stats_nomes[j] + ":" + str(aux[j]))

    for i in range(60):
        print("-", end="")

    transformacoes = [[1, 1, 1, 1, 1]]
    transformacoes_nomes = ["Base"]
    press_any("Precione qualquer tecla para continuar")
