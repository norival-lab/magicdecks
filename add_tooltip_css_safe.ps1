# Script para adicionar CSS do tooltip de forma segura
$cssToAdd = @'
            #card-tooltip {
                position: absolute;
                display: none;
                z-index: 1000;
                border: 2px solid #333;
                border-radius: 8px;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
                pointer-events: none;
            }
            #card-tooltip img {
                width: 200px;
                height: auto;
                border-radius: 6px;
            }
            .card-name {
                cursor: pointer;
            }
'@

# Lista de arquivos a processar (excluindo os que já têm CSS ou não precisam)
$filesToProcess = @(
    '1994.html', '1995.html', '1996.html', '1997.html', '1998.html', '1999.html',
    '2000.html', '2001.html', '2002.html', '2003.html', '2004.html', '2005.html',
    '2006.html', '2007.html', '2008.html', '2009.html', '2010.html', '2011.html',
    '2012.html', '2013.html', '2014.html', '2015.html', '2016.html', '2017.html',
    '2018.html', '2019.html', '2022.html',
    'top-10-caros.html', 'top-10-decks-caros.html', 'top-10-legacy.html',
    'top-10-modern.html', 'top-10-pauper.html', 'top-10-pioneer.html', 'top-10-vintage.html'
)

foreach ($file in $filesToProcess) {
    $filePath = "c:\Users\Admin\magicdecks\$file"
    
    if (Test-Path $filePath) {
        try {
            # Lê todo o conteúdo do arquivo
            $content = Get-Content $filePath -Raw -Encoding UTF8
            
            # Verifica se já tem o CSS do tooltip
            if ($content -notmatch '#card-tooltip') {
                # Procura pela tag </style> e adiciona o CSS antes dela
                if ($content -match '</style>') {
                    $newContent = $content -replace '</style>', "$cssToAdd`n        </style>"
                    
                    # Salva o arquivo com o novo conteúdo
                    Set-Content -Path $filePath -Value $newContent -Encoding UTF8
                    Write-Host "CSS adicionado ao arquivo: $file"
                } else {
                    Write-Host "Arquivo $file não possui tag </style>"
                }
            } else {
                Write-Host "Arquivo $file já possui CSS do tooltip"
            }
        } catch {
            Write-Host "Erro ao processar $file : $($_.Exception.Message)"
        }
    } else {
        Write-Host "Arquivo não encontrado: $file"
    }
}

Write-Host "Processamento concluído!"