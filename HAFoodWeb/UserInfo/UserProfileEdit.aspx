<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserProfileEdit.aspx.cs" Inherits="HAFoodWeb.UserProfileEdit" Async="true" %>


<!DOCTYPE html>
<html>
<head runat="server">
    <title>Chỉnh sửa thông tin cá nhân</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f8f9fa;
        }

        .edit-container {
            max-width: 500px;
            margin: 30px auto;
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }

        .edit-container h2 {
            text-align: center;
            margin-bottom: 20px;
        }

        .avatar-preview {
            display: block;
            width: 140px;
            height: 140px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #ddd;
            margin: 0 auto 15px;
        }

        .form-field {
            margin-bottom: 12px;
        }

        .form-field label {
            display: block;
            font-weight: bold;
            margin-bottom: 6px;
        }

        .form-field input[type="text"],
        .form-field input[type="email"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
            box-sizing: border-box;
        }

        .form-field input[disabled] {
            background-color: #f1f1f1;
        }

        .aspNetButton {
            width: 60%;
            padding: 12px;
            margin-top: 10px;
            border: none;
            border-radius: 20px;
            background-color: #e55a00;
            color: white;
            font-size: 16px;
            cursor: pointer;
            box-shadow: 0 4px 10px rgba(255, 123, 0, 0.3);
            transition: background-color 0.3s ease, transform 0.2s;
            display: block;
            margin-left: auto;
            margin-right: auto;
            text-align: center;
            text-decoration: none;
            line-height: normal;
        }

        .aspNetButton:hover:not(:disabled) {
            background-color: #d14e00;
            transform: translateY(-2px);
        }

        /* Back button style */
        .edit-container {
            position: relative; 
            max-width: 500px;
            margin: 30px auto;
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }

        .backButton {
            position: absolute;
            top: 14px;
            left: 14px;

            display: inline-flex;
            align-items: center;
            gap: 8px;

            padding: 8px 12px;
            border: 1px solid #ced4da;      
            background-color: transparent;  
            color: #6c757d;                 
            font-size: 14px;
            border-radius: 10px;            
            text-decoration: none;
            cursor: pointer;

            box-shadow: none;
            transition: background-color .12s ease, color .12s ease, transform .08s;
            z-index: 10;
        }

.backButton:hover {
    background-color: rgba(0,0,0,0.03);
    color: #495057;
    transform: translateY(-1px);
}


        .success-message {
            color: green;
            text-align: center;
            margin-bottom: 15px;
            font-weight: bold;
        }

        .error-message {
            color: red;
            text-align: center;
            margin-bottom: 15px;
            font-weight: bold;
        }

        .field-error {
            color: #d9534f;
            font-size: 13px;
            margin-top: 6px;
            display: none;
        }

        /* Toast nhỏ gọn, nổi trên cùng header */
        .toast {
            position: fixed;
            top: 20px;             
            right: 15px;           
            background-color: #28a745;
            color: #fff;
            padding: 8px 14px;      
            border-radius: 6px;
            font-size: 14px;        
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 6px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
            opacity: 0;
            transform: translateY(-15px);
            transition: all 0.35s ease;
            z-index: 99999; 
        }

        .toast.show {
            opacity: 1;
            transform: translateY(0);
        }

        .toast.success { background-color: #28a745; }
        .toast.error   { background-color: #d9534f; }

        .toast i {
            font-size: 16px;
        }

    </style>
</head>

<body>
    <form id="form1" runat="server">

        <div class="edit-container">
            <h2>Chỉnh sửa thông tin</h2>

            <a id="btnBack" class="backButton" href="<%= ResolveUrl("~/UserInfo/UserProfile.aspx") %>" aria-label="Quay lại Hồ sơ của tôi">
                <i class="fa-solid fa-arrow-left me-2"></i>Quay lại
            </a>

            <asp:Image ID="imgAvatar" runat="server" CssClass="avatar-preview" />

            <div class="form-field">
                <label for="fileAvatar">Thay đổi ảnh đại diện</label>
                <asp:FileUpload ID="fileAvatar" runat="server" />
            </div>

            <div class="form-field">
                <label for="txtFullName">Họ và tên</label>
                <asp:TextBox ID="txtFullName" runat="server" />
                <div id="fullNameError" class="field-error">Thông báo lỗi tên</div>
            </div>

            <div class="form-field">
                <label for="txtEmail">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" Enabled="false" />
            </div>

            <div class="form-field">
                <label for="txtPhone">Số điện thoại</label>
                <asp:TextBox ID="txtPhone" runat="server" MaxLength="10" />
                <div id="phoneError" class="field-error">Thông báo lỗi số điện thoại</div>
            </div>

            <!-- Server-side chung -->
            <asp:Label ID="lblMessage" runat="server" EnableViewState="false"></asp:Label>

            <!-- OnClientClick trả về false sẽ ngăn postback -->
            <asp:Button ID="btnSave" runat="server" Text="Lưu thay đổi" CssClass="aspNetButton"
                        OnClick="btnSave_Click" OnClientClick="return validateForm();" />
        </div>

        <!-- Toast (dùng 1 div, type được set bằng class) -->
        <div id="toast" class="toast">
            <i id="toastIcon" class="fa-solid fa-circle-check"></i>
            <span id="toastMessage"></span>
        </div>

        <script>
            // Client-side regexes
            var nameRegex = /^\p{L}[\p{L}\s]*$/u;
            var phoneRegex = /^0\d{9}$/;

            var fullNameInput = document.getElementById('<%= txtFullName.ClientID %>');
            var phoneInput = document.getElementById('<%= txtPhone.ClientID %>');
            var fullNameError = document.getElementById('fullNameError');
            var phoneError = document.getElementById('phoneError');
            var lblMessageClientId = '<%= lblMessage.ClientID %>';

            function validateFullName() {
                var val = fullNameInput.value.trim();
                if (!val) {
                    fullNameError.innerText = '❌ Vui lòng nhập họ và tên.';
                    fullNameError.style.display = 'block';
                    return false;
                }
                try {
                    if (!nameRegex.test(val)) {
                        fullNameError.innerText = '❌ Tên không được chứa ký tự đặc biệt hoặc số.';
                        fullNameError.style.display = 'block';
                        return false;
                    }
                } catch (e) {
                    var fallback = /^[A-Za-zÀ-ỹ\s]+$/u;
                    if (!fallback.test(val)) {
                        fullNameError.innerText = '❌ Tên không được chứa ký tự đặc biệt hoặc số.';
                        fullNameError.style.display = 'block';
                        return false;
                    }
                }
                fullNameError.style.display = 'none';
                return true;
            }

            function validatePhone() {
                var val = phoneInput.value.trim();
                if (!val) {
                    phoneError.innerText = '❌ Vui lòng nhập số điện thoại.';
                    phoneError.style.display = 'block';
                    return false;
                }
                if (val.length !== 9) {
                    phoneError.innerText = '❌ Số điện thoại phải gồm đúng 10 chữ số.';
                    phoneError.style.display = 'block';
                    return false;
                }
                if (!val.startsWith('0')) {
                    phoneError.innerText = '❌ Số điện thoại phải bắt đầu bằng số 0.';
                    phoneError.style.display = 'block';
                    return false;
                }
                if (!phoneRegex.test(val)) {
                    phoneError.innerText = '❌ Số điện thoại chỉ được chứa ký tự số.';
                    phoneError.style.display = 'block';
                    return false;
                }
                phoneError.style.display = 'none';
                return true;
            }

            function validateForm() {
                var lbl = document.getElementById(lblMessageClientId);
                if (lbl) lbl.innerText = '';

                var okName = validateFullName();
                var okPhone = validatePhone();
                return okName && okPhone;
            }

            fullNameInput.addEventListener('input', function () {
                var lbl = document.getElementById(lblMessageClientId);
                if (lbl) lbl.innerText = '';
                validateFullName();
            });
            fullNameInput.addEventListener('blur', validateFullName);

            phoneInput.addEventListener('input', function () {
                var lbl = document.getElementById(lblMessageClientId);
                if (lbl) lbl.innerText = '';
                validatePhone();
            });
            phoneInput.addEventListener('blur', validatePhone);

            function showToast(message, type) {
                var toast = document.getElementById("toast");
                var toastMsg = document.getElementById("toastMessage");
                var toastIcon = document.getElementById("toastIcon");

                toast.classList.remove('success', 'error', 'show');

                if (type === 'success') {
                    toast.classList.add('success');
                    toastIcon.className = 'fa-solid fa-circle-check';
                } else {
                    toast.classList.add('error');
                    toastIcon.className = 'fa-solid fa-triangle-exclamation';
                }

                toastMsg.innerText = message;
                // show
                toast.classList.add("show");

                setTimeout(function () {
                    toast.classList.remove("show");
                }, 3000);
            }
        </script>
    </form>
</body>
</html>