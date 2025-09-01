# Script para atualizar todos os arquivos HTML com o mesmo padrao de tooltip do 2024.html

# Define o CSS padrao do tooltip
$tooltipCSS = @'
            /* Estilo para a "caixinha" da imagem da carta */
            #card-tooltip {
                position: fixed; /* Usa 'fixed' para se posicionar relativo a janela */
                display: none;
                z-index: 100;
                border: 2px solid #6366f1; /* indigo-500 */
                border-radius: 10px;
                overflow: hidden;
                box-shadow: 0 10px 25px rgba(0,0,0,0.4);
                pointer-events: none; /* Impede que o tooltip interfira com o mouse */
            }
            #card-tooltip img {
                display: block;
                width: 250px; /* Tamanho da imagem */
                height: auto;
            }
            /* Estilo para o nome da carta, para indicar que e interativo */
            .card-name {
                cursor: pointer;
                /* text-decoration: underline; */
                /* text-decoration-style: dotted; */
                /* text-decoration-color: #9ca3af; */ /* gray-400 */
            }
'@

# Define o JavaScript padrao do tooltip
$tooltipJS = @'
        <!-- Script para o tooltip da imagem da carta -->
        <script>
            // Cria o elemento tooltip uma vez e anexa ao body
            const tooltip = document.createElement('div');
            tooltip.id = 'card-tooltip';
            tooltip.innerHTML = '<img>';
            document.body.appendChild(tooltip);
            const tooltipImage = tooltip.querySelector('img');

            // Pega todos os elementos que devem acionar o tooltip
            const cardSpans = document.querySelectorAll('.card-name');

            // Funcao para atualizar a posicao do tooltip
            const updateTooltipPosition = (e) => {
                // Adiciona um pequeno deslocamento para evitar cintilacao/piscar
                let x = e.clientX + 15;
                let y = e.clientY + 15;

                const tooltipRect = tooltip.getBoundingClientRect();

                // Impede que o tooltip saia da borda direita da tela
                if (x + tooltipRect.width > window.innerWidth) {
                    x = e.clientX - tooltipRect.width - 15;
                }
                // Impede que o tooltip saia da borda inferior da tela
                if (y + tooltipRect.height > window.innerHeight) {
                    y = e.clientY - tooltipRect.height - 15;
                }

                tooltip.style.left = `${x}px`;
                tooltip.style.top = `${y}px`;
            };

            cardSpans.forEach(span => {
                span.addEventListener('mouseover', (e) => {
                    const cardName = span.getAttribute('data-card');
                    if (cardName) {
                        // Usa a API do Scryfall para imagens de cartas. E otima para isso.
                        // A versao 'normal' tem um bom tamanho. 'large' tambem esta disponivel.
                        const imageUrl = `https://api.scryfall.com/cards/named?exact=${encodeURIComponent(cardName)}&format=image&version=normal`;
                        tooltipImage.src = imageUrl;
                        
                        // Espera a imagem carregar para obter as dimensoes corretas antes de mostrar
                        tooltipImage.onload = () => {
                            tooltip.style.display = 'block';
                            updateTooltipPosition(e); // Posicao inicial correta
                        }
                    }
                });

                span.addEventListener('mousemove', updateTooltipPosition);

                span.addEventListener('mouseout', () => {
                    tooltip.style.display = 'none';
                    tooltipImage.src = ''; // Limpa o src para parar de carregar se o mouse sair rapido
                });
            });

            // Funcao original para expandir/recolher as listas de deck
            function toggleVisibility(elementId) {
                const element = document.getElementById(elementId);
                if (element) {
                    element.classList.toggle("hidden");
                }
            }
        </script>
'@

# Lista todos os arquivos HTML (exceto 2024.html que ja esta correto)
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html" | Where-Object { $_.Name -ne "2024.html" -and $_.Name -ne "index.html" }

$totalFiles = 0
$updatedFiles = 0

foreach ($file in $htmlFiles) {
    $totalFiles++
    Write-Host "Processando: $($file.Name)"
    
    try {
        # Le o conteudo do arquivo
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        
        # Substitui o JavaScript do tooltip
        if ($content -match '(?s)\s*<!--\s*Script para o tooltip.*?</script>') {
            $content = $content -replace '(?s)\s*<!--\s*Script para o tooltip.*?</script>', $tooltipJS
            $updatedFiles++
        } elseif ($content -match '(?s)</body>') {
            # Se nao tem script do tooltip, adiciona antes do </body>
            $content = $content -replace '(?s)(\s*)</body>', "`n$tooltipJS`n`$1</body>"
            $updatedFiles++
        }
        
        # Salva o arquivo atualizado
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "Atualizado: $($file.Name)"
        
    } catch {
        Write-Host "Erro ao processar $($file.Name): $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "Resumo:"
Write-Host "Total de arquivos processados: $totalFiles"
Write-Host "Arquivos atualizados com sucesso: $updatedFiles"
Write-Host "Todos os arquivos agora tem o mesmo padrao de tooltip do 2024.html!"