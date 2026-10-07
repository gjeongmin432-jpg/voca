@echo off
chcp 65001 > nul
title 깃허브(GitHub Pages) 자동 배포 도우미
cls

echo ===============================================================
echo   🚀 [보카마스터] 깃허브 무료 웹 호스팅 자동 배포
echo   PC를 켜두지 않아도 365일 어디서나 스마트폰 앱으로 구동됩니다!
echo ===============================================================
echo.
echo   [1단계] GitHub(github.com)에 로그인 후 아래 새 저장소를 만드세요:
echo   - 링크: https://github.com/new
echo   - Repository name 입력 (예: voca 또는 word-game)
echo   - 'Public' 선택 후 맨 아래 [Create repository] 초록색 버튼 클릭!
echo.
echo   [2단계] 생성된 저장소의 HTTPS 주소를 복사해 아래에 붙여넣으세요.
echo   (예: https://github.com/내아이디/voca.git)
echo.
echo ===============================================================
set /p REPO_URL="👉 깃허브 저장소 주소를 붙여넣고 엔터(Enter): "

if "%REPO_URL%"=="" (
    echo.
    echo ❌ 주소가 입력되지 않았습니다. 다시 실행해 주세요.
    pause
    exit /b
)

echo.
echo ⏳ 깃허브에 연결하고 파일들을 업로드합니다...
echo.

git remote remove origin >nul 2>&1
git remote add origin %REPO_URL%
git branch -M main
git add .
git commit -m "Deploy VocaMaster PWA" >nul 2>&1
git push -u origin main

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ⚠️ 업로드 중 오류가 발생했거나 로그인 창이 떴을 수 있습니다.
    echo (처음 한 번은 깃허브 로그인 창에서 'Sign in with your browser'를 눌러주세요)
    echo.
    pause
    exit /b
)

echo.
echo ===============================================================
echo   🎉 파일 업로드가 성공적으로 완료되었습니다!
echo ===============================================================
echo.
echo   [마지막 3단계: 깃허브 웹사이트에서 무료 호스팅 켜기]
echo   1. 깃허브 저장소 페이지의 상단 탭에서 [Settings] (설정) 클릭
echo   2. 왼쪽 사이드바 메뉴에서 [Pages] 클릭
echo   3. 'Build and deployment' ➔ Branch 항목에서:
echo      [None ▾] 을 눌러 [main] 으로 변경하고 [Save] 버튼 클릭!
echo.
echo   약 1~2분 뒤 나만의 고유 인터넷 주소가 생성됩니다:
echo   👉 https://내아이디.github.io/저장소이름/
echo.
echo   이 주소를 스마트폰으로 열고 '홈 화면에 추가'하시면,
echo   PC를 끄셔도 365일 24시간 언제나 모바일 앱으로 실행됩니다!
echo ===============================================================
echo.
pause
