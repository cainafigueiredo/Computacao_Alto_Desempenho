### Planejamento da implementação

- Implementações da operação PRODUTO MATRIZ-VETOR: $$I = \{i_{C,1}, i_{C,2}, i_{Fortran,1}, i_{Fortran,2}\}$$
    - *Entrada:* Matriz $$A_{n \times n}$$, Vetor $$x_{n \times 1}$$
    - *Saída:* Vetor $$b_{n \times 1}$$
- Procedimento GERAR_GRÁFICO:
    - *Entrada:* $$i \in{I}$$
    - *Saída:* Gráfico bidimensional, onde $$x = f(n)$$ e $$y = T(n)$$, sendo $$T(n)$$ o tempo necessário para a execução da operação PRODUTO MATRIZ-VETOR.
    1. amostras $$\leftarrow$$ OBTER_AMOSTRAS($$i$$) // pares $$(n, T(n))$$
    2. Aplica $$f(n)$$ nos valores de $$n$$ em amostras
    2. Plota gráfico de linha $$T(n) \times f(n)$$
- Procedimento OBTER_AMOSTRAS:
    - *Entrada:* $$i$$
    - *Saída:* pares $$(n, T(n))$$
    1. $$n_{max} \leftarrow$$ OBTER_NMAX(4GB) 
    2. amostras $$\leftarrow$$ []
    2. Para $$(n = 1; n \leq n_{max}; n = 2n$$ faça
    3. |------ $$A_{n \times n} \leftarrow$$ GERA_MATRIZ($$n,n$$)
    4. |------ $$x_{n \times 1} \leftarrow$$ GERA_VETOR($$n$$)
    5. |------ $$b_{n \times 1} \leftarrow$$ Aloca memória para um vetor com dimensão $$n$$
    6. |------ Se $$A_{n \times n}, x_{n \times 1}, b_{n \times 1}$$ foram alocados, então
    5. |------------ $$T_{1} \leftarrow$$ Inicia contagem de tempo
    5. |------------ $$b_{n \times 1} \leftarrow i(A_{n \times n}, x_{n \times 1})$$ 
    6. |------------ $$T_{2} \leftarrow$$ Finaliza contagem de tempo
    7. |------------ Adiciona $$(n, T_{2} - T_{1})$$ em amostras
    8. |------------ Descarta $$A_{n \times n}, x_{n \times 1}, b_{n \times 1}$$ da memória
    9. |------ Senão
    10. |------------ Finaliza loop
    11. Retorna amostras
- Procedimento OBTER_NMAX:
    - *Entrada:* $$available\_ram$$, i.e,  RAM disponível na máquina; $$bytes\_per\_element$$, i.e, quantidades de bytes por elemento
    - *Saída:* $$n_{max}$$, i.e, o valor máximo que o parâmetro $$n$$ pode assumir devido a restrições de memória
    1. $$n_{ideal} \leftarrow floor(-1 + \sqrt{1+\frac{available\_ram}{bytes\_per\_element}})$$ 
    2. $$n_{current} \leftarrow floor(\frac{n_{ideal}}{2})$$
    2. $$n_{last} \leftarrow any$$ 
    3. Enquanto $$n_{last} \ne n_{current}$$
    2. |------ Tente alocar uma matriz $$A_{n \times n}$$ e dois vetores, $$x_{n \times 1}\ e b_{n \times 1}$$
    3. |------ Se deu certo, então
    4. |------------ $$n_{last} \leftarrow n_{current}$$
    5. |------------ $$n_{current} \leftarrow floor(\frac{n_{ideal} + n_{current}}{2})$$
    6. |------ Senão
    7. |------------ $$n_{current} \leftarrow floor(\frac{n_{last} + n_{current}}{2})$$
    8. |------ Descarta $$A_{n \times n}, x_{n \times 1}, b_{n \times 1}$$ da memória
    9. Retorna $$n_{current}$$
