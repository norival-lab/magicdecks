# Script para converter nomes de cartas em texto simples para estrutura <span class="card-name" data-card="...">
# Analisa arquivos HTML e converte cartas encontradas em divs com class="text-gray-300"

$files = @(
    "1994.html", "1995.html", "1996.html", "1997.html", "1998.html", "1999.html",
    "2000.html", "2001.html", "2002.html", "2003.html", "2004.html", "2005.html",
    "2006.html", "2007.html", "2008.html", "2009.html", "2010.html", "2011.html",
    "2012.html", "2013.html", "2014.html", "2015.html", "2016.html", "2017.html",
    "2018.html", "2019.html", "2020.html", "2021.html", "2022.html", "2023.html"
)

$processedFiles = 0
$totalCardsConverted = 0

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Processando arquivo: $file" -ForegroundColor Green
        
        $content = Get-Content $file -Raw -Encoding UTF8
        $originalContent = $content
        $fileCardsConverted = 0
        
        # Regex para encontrar padroes de cartas em divs text-gray-300
        # Padrao: numero + nome da carta (pode ter <br /> no meio)
        $cardPattern = '(<div class="text-gray-300">)([^<]+(?:<br\s*/?>[^<]+)*)(</div>)'
        
        $content = [regex]::Replace($content, $cardPattern, {
            param($match)
            
            $openTag = $match.Groups[1].Value
            $cardContent = $match.Groups[2].Value
            $closeTag = $match.Groups[3].Value
            
            # Divide o conteudo por <br /> para processar cada linha
            $lines = $cardContent -split '<br\s*/?>' | ForEach-Object { $_.Trim() }
            $processedLines = @()
            
            foreach ($line in $lines) {
                if ($line -match '^\s*$') { continue } # Pula linhas vazias
                
                # Regex para capturar: numero + nome da carta
                # Exemplos: "4 Lightning Bolt", "1 Serra Angel", "20 Mountain"
                if ($line -match '^(\d+)\s+(.+)$') {
                    $quantity = $matches[1]
                    $cardName = $matches[2].Trim()
                    
                    # Converte para span com tooltip
                    $spanCard = "$quantity <span class=`"card-name`" data-card=`"$cardName`">$cardName</span>"
                    $processedLines += $spanCard
                    $script:fileCardsConverted++
                } else {
                    # Se nao corresponder ao padrao, mantem o texto original
                    $processedLines += $line
                }
            }
            
            # Reconstroi o conteudo com <br /> entre as linhas
            $newContent = $processedLines -join '<br />'
            return "$openTag$newContent$closeTag"
        })
        
        # Salva apenas se houve mudancas
        if ($content -ne $originalContent) {
            Set-Content -Path $file -Value $content -Encoding UTF8
            Write-Host "  Convertidas $fileCardsConverted cartas em $file" -ForegroundColor Cyan
            $totalCardsConverted += $fileCardsConverted
            $processedFiles++
        } else {
            Write-Host "  Nenhuma carta encontrada para conversao em $file" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Arquivo nao encontrado: $file" -ForegroundColor Red
    }
}

Write-Host "`n=== RESUMO ===" -ForegroundColor Magenta
Write-Host "Arquivos processados: $processedFiles" -ForegroundColor Green
Write-Host "Total de cartas convertidas: $totalCardsConverted" -ForegroundColor Green
Write-Host "Conversao concluida!" -ForegroundColor Green