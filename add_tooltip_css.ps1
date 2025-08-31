# Script para adicionar CSS do tooltip em todos os arquivos HTML
$cssToAdd = @'
            /* Estilo para a "caixinha" da imagem da carta */
            #card-tooltip {
                position: fixed; /* Usa 'fixed' para se posicionar relativo à janela */
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
            /* Estilo para o nome da carta, para indicar que é interativo */
            .card-name {
                cursor: pointer;
            }
'@

# Lista de arquivos para processar
$files = Get-ChildItem -Path "c:\Users\Admin\magicdecks" -Filter "*.html" | Where-Object { $_.Name -ne "2024.html" -and $_.Name -ne "index.html" }

foreach ($file in $files) {
    Write-Host "Processando: $($file.Name)"
    
    # Le o conteudo do arquivo
    $content = Get-Content -Path $file.FullName -Raw
    
    # Verifica se ja tem o CSS do tooltip
    if ($content -notmatch "#card-tooltip") {
        # Procura pela tag de fechamento do style e adiciona o CSS antes dela
        $pattern = "(.*)(\s*</style>.*)"
        if ($content -match $pattern) {
            $beforeStyle = $matches[1]
            $afterStyle = $matches[2]
            
            # Adiciona o CSS do tooltip
            $newContent = $beforeStyle + $cssToAdd + $afterStyle
            
            # Escreve o novo conteudo no arquivo
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
            Write-Host "  CSS adicionado com sucesso"
        } else {
            Write-Host "  Nao foi possivel encontrar a tag de fechamento do style"
        }
    } else {
        Write-Host "  CSS ja existe, pulando..."
    }
}

Write-Host "Processamento concluido!"