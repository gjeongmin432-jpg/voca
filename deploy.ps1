[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "보카마스터 깃허브 자동 배포"

Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  🚀 [보카마스터] 깃허브(GitHub Pages) 자동 배포 도우미" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

# 클립보드에 깃허브 주소가 이미 복사되어 있는지 확인
$clipText = ""
try {
    $clipText = [System.Windows.Forms.Clipboard]::GetText().Trim()
} catch {}

$defaultUrl = ""
if ($clipText -like "*github.com*") {
    $defaultUrl = $clipText
    Write-Host "📋 클립보드에서 깃허브 주소를 자동 감지했습니다: $defaultUrl" -ForegroundColor Green
    Write-Host ""
}

$promptMsg = "생성하신 깃허브 저장소 HTTPS 주소를 입력하세요:`n`n(예: https://github.com/아이디/저장소이름.git)"
$repoUrl = [Microsoft.VisualBasic.Interaction]::InputBox($promptMsg, "보카마스터 깃허브 자동 배포", $defaultUrl)

if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Write-Host ""
    Write-Host "❌ 주소가 입력되지 않아 작업을 취소했습니다." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "엔터(Enter) 키를 누르면 창이 닫힙니다..."
    exit
}

$repoUrl = $repoUrl.Trim()
Write-Host "🔗 입력된 깃허브 주소: $repoUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "⏳ 깃허브 연결 및 파일 업로드를 시작합니다..." -ForegroundColor White

try {
    git remote remove origin 2>$null
    git remote add origin $repoUrl
    git branch -M main
    git add .
    git commit -m "Deploy VocaMaster PWA" 2>$null
    
    Write-Host ""
    Write-Host "📤 깃허브로 파일 업로드(git push)를 진행합니다..." -ForegroundColor Yellow
    Write-Host "   (처음 한 번 브라우저 로그인 창이 뜨면 초록색 'Sign in with browser'를 눌러주세요)" -ForegroundColor Gray
    Write-Host ""
    
    git push -u origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "==============================================================" -ForegroundColor Green
        Write-Host "  🎉 깃허브 업로드가 성공적으로 완료되었습니다!" -ForegroundColor Green
        Write-Host "==============================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "  [마지막 설정: 깃허브 웹사이트에서 무료 호스팅 켜기]" -ForegroundColor White
        Write-Host "  1. 깃허브 저장소 웹페이지 상단 메뉴에서 [Settings] 클릭" -ForegroundColor White
        Write-Host "  2. 왼쪽 사이드바 메뉴에서 [Pages] 클릭" -ForegroundColor White
        Write-Host "  3. Branch 항목의 'None'을 'main'으로 바꾸고 [Save] 클릭!" -ForegroundColor White
        Write-Host ""
        Write-Host "  약 1~2분 뒤 인터넷 주소가 활성화됩니다:" -ForegroundColor Yellow
        
        if ($repoUrl -match "github\.com[:/]([^/]+)/([^/\.]+)") {
            $user = $matches[1]
            $repo = $matches[2]
            Write-Host "  👉 https://$user.github.io/$repo/" -ForegroundColor Cyan
        }
        Write-Host ""
        Write-Host "  이제 PC를 끄셔도 스마트폰으로 위 주소에 접속하여 '홈 화면에 추가'하시면 됩니다!" -ForegroundColor White
    } else {
        Write-Host ""
        Write-Host "⚠️ 업로드 도중 오류가 발생했습니다." -ForegroundColor Red
        Write-Host "   - 깃허브 저장소 주소가 올바른지 확인해 주세요." -ForegroundColor Yellow
        Write-Host "   - 브라우저에서 깃허브 권한 승인 창을 확인해 주세요." -ForegroundColor Yellow
    }
} catch {
    Write-Host "오류 발생: $_" -ForegroundColor Red
}

Write-Host ""
Read-Host "엔터(Enter) 키를 누르면 창이 닫힙니다..."
