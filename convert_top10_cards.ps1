# Script para converter nomes de cartas nos arquivos top-10 para estrutura com spans
# Converte cartas que estão em spans coloridos para a estrutura card-name

$topFiles = @(
    "top-10-decks-caros.html",
    "top-10-legacy.html", 
    "top-10-modern.html",
    "top-10-vintage.html",
    "top-10-pauper.html",
    "top-10-pioneer.html",
    "top-10-standard.html"
)

$totalConverted = 0

foreach ($file in $topFiles) {
    $filePath = "c:\Users\Admin\magicdecks\$file"
    
    if (Test-Path $filePath) {
        Write-Host "Processando $file..."
        
        $content = Get-Content $filePath -Raw -Encoding UTF8
        $originalContent = $content
        
        # Padrão para encontrar nomes de cartas em spans coloridos
        # Procura por spans com classes de cor que contêm nomes de cartas
        $cardPatterns = @(
            '<span class="font-semibold text-amber-400">([^<]+)</span>',
            '<span class="font-semibold text-rose-400">([^<]+)</span>',
            '<span class="font-semibold text-emerald-400">([^<]+)</span>',
            '<span class="font-semibold text-blue-400">([^<]+)</span>',
            '<span class="font-semibold text-purple-400">([^<]+)</span>',
            '<span class="font-semibold text-indigo-400">([^<]+)</span>',
            '<span class="font-semibold text-cyan-400">([^<]+)</span>',
            '<span class="font-semibold text-green-400">([^<]+)</span>',
            '<span class="font-semibold text-red-400">([^<]+)</span>',
            '<span class="font-semibold text-yellow-400">([^<]+)</span>'
        )
        
        $fileConverted = 0
        
        foreach ($pattern in $cardPatterns) {
            $matches = [regex]::Matches($content, $pattern)
            
            foreach ($match in $matches) {
                $cardName = $match.Groups[1].Value.Trim()
                
                # Verifica se é realmente um nome de carta (não texto descritivo)
                if ($cardName -match "^[A-Za-z'',\s-]+$" -and $cardName.Length -gt 2 -and $cardName.Length -lt 50) {
                    $originalSpan = $match.Groups[0].Value
                    $newSpan = "<span class=`"card-name`" data-card=`"$cardName`">$cardName</span>"
                    
                    $content = $content -replace [regex]::Escape($originalSpan), $newSpan
                    $fileConverted++
                }
            }
        }
        
        # Também procura por cartas em divs text-gray-300 que podem ter sido perdidas
        $cardPattern2 = '(<div class="text-gray-300">)([^<]+(?:<br\s*/?>[^<]+)*)(</div>)'
        $matches2 = [regex]::Matches($content, $cardPattern2)
        
        foreach ($match in $matches2) {
            $fullMatch = $match.Groups[0].Value
            $openTag = $match.Groups[1].Value
            $cardContent = $match.Groups[2].Value
            $closeTag = $match.Groups[3].Value
            
            # Processa cada linha de carta
            $lines = $cardContent -split '<br\s*/?>' | ForEach-Object { $_.Trim() }
            $processedLines = @()
            
            foreach ($line in $lines) {
                if ($line -match '^(\d+)\s+(.+)$') {
                    $quantity = $matches.Groups[1].Value
                    $cardName = $matches.Groups[2].Value.Trim()
                    
                    if ($cardName -notmatch '<span class="card-name"') {
                        $processedLines += "$quantity <span class=`"card-name`" data-card=`"$cardName`">$cardName</span>"
                        $fileConverted++
                    } else {
                        $processedLines += $line
                    }
                } else {
                    $processedLines += $line
                }
            }
            
            $newContent = $openTag + ($processedLines -join '<br />') + $closeTag
            $content = $content -replace [regex]::Escape($fullMatch), $newContent
        }
        
        if ($content -ne $originalContent) {
            Set-Content $filePath $content -Encoding UTF8
            Write-Host "  Convertidas $fileConverted cartas em $file"
            $totalConverted += $fileConverted
        } else {
            Write-Host "  Nenhuma conversão necessária em $file"
        }
    } else {
        Write-Host "Arquivo $file não encontrado, pulando..."
    }
}

Write-Host "`nTotal de cartas convertidas: $totalConverted"
Write-Host "Conversão dos arquivos top-10 concluída!"