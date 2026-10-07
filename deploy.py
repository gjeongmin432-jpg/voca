import sys
import os
import subprocess
import webbrowser
import tkinter as tk
from tkinter import ttk, messagebox

def main():
    # Set current directory to script directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    root = tk.Tk()
    root.title("보카마스터 - 깃허브(GitHub Pages) 자동 배포 도우미")
    root.geometry("560x420")
    root.resizable(False, False)

    # Style
    style = ttk.Style()
    style.theme_use("clam")

    # Check clipboard for github url
    clipboard_url = ""
    try:
        cb = root.clipboard_get().strip()
        if "github.com" in cb:
            clipboard_url = cb
    except:
        pass

    # Header Frame
    header_frame = tk.Frame(root, bg="#3b82f6", padx=20, pady=16)
    header_frame.pack(fill="x")

    lbl_title = tk.Label(header_frame, text="📚 보카마스터 깃허브 자동 배포", font=("Malgun Gothic", 15, "bold"), fg="white", bg="#3b82f6")
    lbl_title.pack(anchor="w")

    lbl_sub = tk.Label(header_frame, text="PC를 켜두지 않아도 365일 언제 어디서나 스마트폰 앱으로 구동됩니다.", font=("Malgun Gothic", 9), fg="#e0e7ff", bg="#3b82f6")
    lbl_sub.pack(anchor="w", pady=(4, 0))

    # Content Frame
    content = tk.Frame(root, padx=24, pady=16)
    content.pack(fill="both", expand=True)

    # Step 1
    lbl_step1 = tk.Label(content, text="[1단계] GitHub에서 새 저장소를 아직 안 만드셨다면?", font=("Malgun Gothic", 10, "bold"), fg="#1e293b")
    lbl_step1.pack(anchor="w")

    def open_github_new():
        webbrowser.open("https://github.com/new")

    btn_open_new = tk.Button(content, text="🌐 깃허브 새 저장소 만들기 페이지 열기 (github.com/new)", font=("Malgun Gothic", 9, "underline"), fg="#2563eb", bd=0, cursor="hand2", command=open_github_new)
    btn_open_new.pack(anchor="w", pady=(2, 14))

    # Step 2
    lbl_step2 = tk.Label(content, text="[2단계] 생성하신 깃허브 저장소의 HTTPS 주소를 붙여넣어 주세요:", font=("Malgun Gothic", 10, "bold"), fg="#1e293b")
    lbl_step2.pack(anchor="w")

    entry_url = ttk.Entry(content, font=("Segoe UI", 10))
    entry_url.pack(fill="x", pady=(6, 4))
    if clipboard_url:
        entry_url.insert(0, clipboard_url)

    lbl_hint = tk.Label(content, text="예시: https://github.com/내아이디/voca.git", font=("Malgun Gothic", 8), fg="#64748b")
    lbl_hint.pack(anchor="w", pady=(0, 16))

    # Status Label
    lbl_status = tk.Label(content, text="", font=("Malgun Gothic", 9, "bold"), fg="#2563eb")
    lbl_status.pack(pady=4)

    # Execute Deploy
    def start_deploy():
        url = entry_url.get().strip()
        if not url:
            messagebox.showwarning("입력 필요", "깃허브 저장소 주소를 입력해주세요.\n(예: https://github.com/내아이디/저장소이름.git)")
            return
        if "github.com" not in url:
            messagebox.showwarning("주소 형식 확인", "올바른 깃허브 저장소 주소(github.com)를 입력해주세요.")
            return

        btn_deploy.config(state="disabled", text="⏳ 깃허브로 업로드 진행 중...")
        lbl_status.config(text="파일들을 깃허브에 업로드하고 있습니다. 잠시만 기다려주세요...", fg="#2563eb")
        root.update()

        try:
            # Git commands
            subprocess.run(["git", "remote", "remove", "origin"], capture_output=True, text=True)
            subprocess.run(["git", "remote", "add", "origin", url], check=True, capture_output=True, text=True)
            subprocess.run(["git", "branch", "-M", "main"], check=True, capture_output=True, text=True)
            subprocess.run(["git", "add", "."], check=True, capture_output=True, text=True)
            subprocess.run(["git", "commit", "-m", "Deploy VocaMaster PWA"], capture_output=True, text=True)

            # Git push (can pop up browser login if needed)
            res = subprocess.run(["git", "push", "-u", "origin", "main"], capture_output=True, text=True)

            if res.returncode == 0:
                lbl_status.config(text="✅ 업로드 완료!", fg="#10b981")
                
                # Parse user and repo
                user = ""
                repo = ""
                import re
                m = re.search(r"github\.com[:/]([^/]+)/([^/\.]+)", url)
                if m:
                    user = m.group(1)
                    repo = m.group(2)
                    pages_url = f"https://{user}.github.io/{repo}/"
                    settings_pages_url = f"https://github.com/{user}/{repo}/settings/pages"
                else:
                    pages_url = "https://내아이디.github.io/저장소이름/"
                    settings_pages_url = url

                msg = (
                    "🎉 파일 업로드가 성공적으로 완료되었습니다!\n\n"
                    "[마지막 1분 설정]\n"
                    "확인을 누르시면 깃허브 Pages 설정 페이지가 열립니다.\n"
                    "Branch 항목을 'None'에서 'main'으로 바꾸고 [Save]를 눌러주세요!\n\n"
                    f"잠시 후 활성화될 스마트폰 접속 주소:\n{pages_url}"
                )
                messagebox.showinfo("배포 성공", msg)
                if settings_pages_url:
                    webbrowser.open(settings_pages_url)
                root.destroy()
            else:
                err_msg = res.stderr or res.stdout or "알 수 없는 오류가 발생했습니다."
                lbl_status.config(text="❌ 업로드 실패", fg="#ef4444")
                btn_deploy.config(state="normal", text="🚀 지금 바로 깃허브에 올리기")
                messagebox.showerror("업로드 실패", f"깃허브 업로드 중 오류가 발생했습니다:\n\n{err_msg}\n\n- 주소가 정확한지 확인해주세요.\n- 브라우저 로그인 창이 뜨면 로그인을 완료해주세요.")
        except Exception as ex:
            lbl_status.config(text="❌ 오류 발생", fg="#ef4444")
            btn_deploy.config(state="normal", text="🚀 지금 바로 깃허브에 올리기")
            messagebox.showerror("오류", f"실행 중 오류가 발생했습니다:\n{str(ex)}")

    btn_deploy = tk.Button(
        content,
        text="🚀 지금 바로 깃허브에 올리기",
        font=("Malgun Gothic", 11, "bold"),
        bg="#3b82f6",
        fg="white",
        activebackground="#2563eb",
        activeforeground="white",
        cursor="hand2",
        bd=0,
        padx=14,
        pady=10,
        command=start_deploy
    )
    btn_deploy.pack(fill="x", pady=6)

    root.mainloop()

if __name__ == "__main__":
    main()
