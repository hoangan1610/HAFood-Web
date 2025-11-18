<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="SpinPage.aspx.cs"
    Inherits="HAFoodWeb.HomePage.SpinPage"
    Async="true" %>

<%@ Register Src="~/Control/Header.ascx" TagPrefix="uc" TagName="Header" %>
<%@ Register Src="~/Control/Footer.ascx" TagPrefix="uc" TagName="Footer" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>Vòng quay may mắn - HAFood</title>

    <meta name="api-base" content="<%: System.Configuration.ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "" %>" />
    <script>
        window.__API_BASE = (document.querySelector('meta[name="api-base"]')?.content || '').replace(/\/+$/, '');
    </script>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Great+Vibes&family=Playfair+Display:wght@600;700&display=swap&subset=latin,vietnamese" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif:ital,wght@0,400;0,700;1,400;1,700&display=swap&subset=latin,vietnamese" rel="stylesheet">

    <style>
        body { line-height: 1.55; font-family: "Noto Serif","Times New Roman",Times,serif; }

        .spin-wrap{
            padding: 40px 0 60px;
        }
        .spin-card{
            max-width: 480px;
            margin: 0 auto;
            background:#fff;
            border-radius: 24px;
            box-shadow: 0 .75rem 2rem rgba(15,23,42,.15);
            padding: 24px 20px 32px;
            text-align:center;
        }
        .spin-title{
            font-family:"Georgia","Noto Serif","Times New Roman",Times,serif;
            font-weight:700;
            font-style:italic;
            font-size:1.6rem;
            margin-bottom:4px;
        }
        .spin-sub{
            color:#6b7280;
            font-size:.95rem;
            margin-bottom:20px;
        }
        .screen-3, .screen-4{ max-width: 420px; margin: 0 auto; }
        .screen-4 img{ max-width:220px; height:auto; }

        @media (max-width:576px){
            .spin-card{ margin: 0 12px; padding: 20px 16px 26px; }
        }
    </style>
</head>
<body>
<form runat="server">
    <asp:ScriptManager ID="sm" runat="server" />

    <!-- HEADER -->
    <uc:Header ID="Header1" runat="server" />

    <!-- NỘI DUNG VÒNG QUAY -->
    <section class="spin-wrap">
        <div class="container">
            <div class="spin-card">
                <h2 class="spin-title">Vòng quay may mắn</h2>
                <p class="spin-sub">
                    Đăng nhập và quay để nhận ưu đãi cho đơn hàng HAFood của bạn.
                </p>

                <p id="spin_turns_label" class="small text-secondary mb-2"></p>

                <!-- MÀN HÌNH VÒNG QUAY -->
                <div class="screen-3">
                    <canvas id="mycanvas" width="500" height="500"></canvas>
                    <a href="javascript:void(0)" id="btn_spin"
                       onclick="clickSpinRota()"
                       class="text-primary mt-3 h5 d-block text-center text-decoration-none">
                        Bấm để quay
                    </a>
                </div>

                <!-- MÀN HÌNH KẾT QUẢ -->
                <div class="screen-4" style="display:none">
                    <h5 class="text-center mt-3 mb-3">
                        Chúc mừng bạn nhận được<br /> phần quà
                    </h5>
                    <div class="img-reward text-center mb-2">
                        <img id="img_result_spin"
                             src="<%= ResolveUrl("~/assets/spin/item-random/item1.png") %>" />
                    </div>
                    <h3 class="text-center mt-2 mb-2"
                        id="name_result_spin"
                        style="color:#2600ff"></h3>

                    <!-- Thông điệp chi tiết -->
                    <p id="spin_result_message" class="mt-2 mb-2 text-muted"></p>

                    <button type="button"
                            class="btn btn-outline-primary mt-2"
                            onclick="backToWheel()">
                        Quay tiếp
                    </button>
                </div>
            </div>
        </div>
    </section>

    <!-- FOOTER -->
    <uc:Footer ID="Footer1" runat="server" />

    <!-- JS: jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- CreateJS libs -->
    <script src="https://code.createjs.com/1.0.0/easeljs.min.js"></script>
    <script src="https://code.createjs.com/1.0.0/tweenjs.min.js"></script>

    <!-- SCRIPT LOGIC VÒNG QUAY -->
    <script>

        

        var iconLayer;               // <--- thêm
        var baseAngles = [];         // <--- thêm, lưu góc từng ô
        var ICON_OFFSET = 95;        // <--- thay cho offsetIcon cũ

        // ====== GLOBAL ======
        var stage, imgRotation, imgCoverRota, centerRota;
        var item_random_file = "item-random";

        var remainingSpins = null;   // số lượt quay chưa dùng
        var hasLogin = true;         // flag tạm để biết có 401 hay không

        var linkImg = "<%= ResolveUrl("~/assets/spin/") %>";

        var imgContainRota = new Image();
        var imgCenterRota = new Image();
        imgContainRota.src = linkImg + "Vong-quay-nen.png";
        imgCenterRota.src = linkImg + "kim-vong-quay.png";

        var spinning = false;
        var spinningContinuous = false;
        var spinSpeed = 720;
        var totalRota = 5;
        var timeRota = 4000;

        function updateSpinTurnsLabel() {
            var el = document.getElementById("spin_turns_label");
            if (!el) return;

            if (!hasLogin) {
                el.textContent = "Vui lòng đăng nhập để sử dụng vòng quay.";
                return;
            }

            if (remainingSpins == null) {
                el.textContent = "Đang kiểm tra lượt quay...";
                return;
            }

            if (remainingSpins > 0) {
                el.textContent = "Bạn còn " + remainingSpins + " lượt quay.";
            } else {
                el.textContent = "Bạn đã sử dụng hết lượt quay.";
            }
        }

        function setSpinButtonState(isSpinning) {
            var btn = document.getElementById("btn_spin");
            if (!btn) return;
            if (isSpinning) {
                btn.classList.add("disabled");
                btn.style.pointerEvents = "none";
                btn.textContent = "Đang quay...";
            } else {
                btn.classList.remove("disabled");
                btn.style.pointerEvents = "";
                btn.textContent = "Bấm để quay";
            }
        }

        function init() {
            stage = new createjs.Stage("mycanvas");
            createjs.Touch.enable(stage);
            stage.enableMouseOver();

            imgCoverRota = new createjs.Container();
            stage.addChild(imgCoverRota);

            imgRotation = new createjs.Container();
            imgCoverRota.addChild(imgRotation);

            // thêm layer icon (không quay theo imgRotation)
            iconLayer = new createjs.Container();
            imgCoverRota.addChild(iconLayer);


            var toLoad = 2;
            function onLoadedImg() {
                toLoad--;
                if (toLoad === 0 && totalItem > 0) buildWheel();
            }
            if (imgContainRota.complete) onLoadedImg(); else imgContainRota.onload = onLoadedImg;
            if (imgCenterRota.complete) onLoadedImg(); else imgCenterRota.onload = onLoadedImg;

            createjs.Ticker.framerate = 60;
            createjs.Ticker.on("tick", function (evt) {
                if (spinningContinuous && imgRotation) {
                    imgRotation.rotation += spinSpeed * (evt.delta / 1000);
                }

                // cập nhật vị trí icon theo góc mới của bánh
                updateAllIconsPosition();

                stage.update(evt);
            });


            window.addEventListener('resize', handleResize);
            handleResize();
        }

        // Màu các miếng "bánh pizza"
        const SLICE_COLORS = [
            "rgba(255, 255, 255, 0.18)",
            "rgba(255, 190, 120, 0.35)"
        ];

        function buildWheel() {
            imgRotation.removeAllChildren();

            // không xóa cả imgCoverRota vì còn iconLayer
            imgCoverRota.removeAllChildren();
            imgCoverRota.addChild(imgRotation);
            imgCoverRota.addChild(iconLayer);

            iconLayer.removeAllChildren();
            baseAngles = [];

            imgCoverRota.x = stage.canvas.width / 2;
            imgCoverRota.y = stage.canvas.height / 2;

            // Nền vòng quay
            var wheel = new createjs.Bitmap(imgContainRota);
            wheel.regX = imgContainRota.width / 2;
            wheel.regY = imgContainRota.height / 2;
            imgRotation.addChild(wheel);

            var wheelRadius = imgContainRota.width / 2;
            var sliceOuter = wheelRadius - 4;         // icon cách mép bao nhiêu px

            // ===== VẼ MIẾNG "BÁNH PIZZA" XEN KẼ =====
            for (let i = 0; i < totalItem; i++) {
                var startDeg = degItem * i;
                var endDeg = startDeg + degItem;

                // convert sang radian, gốc 0° ở phía trên (trục Oy âm)
                var startRadArc = (startDeg - 90) * Math.PI / 180;
                var endRadArc = (endDeg - 90) * Math.PI / 180;

                var slice = new createjs.Shape();
                var g = slice.graphics;

                var color = SLICE_COLORS[i % SLICE_COLORS.length];

                g.beginFill(color);
                g.moveTo(0, 0);
                // vẽ cạnh trái
                g.lineTo(
                    Math.cos(startRadArc) * sliceOuter,
                    Math.sin(startRadArc) * sliceOuter
                );
                // vẽ cung tròn ngoài
                g.arc(0, 0, sliceOuter, startRadArc, endRadArc);
                g.closePath();
                g.endFill();

                imgRotation.addChild(slice);
            }

            // ===== VẼ ICON PHẦN THƯỞNG (đứng thẳng) =====
            for (let i = 0; i < totalItem; i++) {
                const angleDeg = degItem * i + degItem / 2;
                baseAngles[i] = angleDeg; // lưu lại

                let img = new Image();
                img.src = linkImg + item_random_file + "/" + arrItem[i].src + ".png";

                img.onload = function () {
                    let bmp = new createjs.Bitmap(img);
                    bmp.regX = img.width / 2;
                    bmp.regY = img.height / 2;

                    // lưu index để tick() reposition
                    bmp.__slotIndex = i;

                    const maxW = 72, maxH = 104;
                    const scale = Math.min(1, maxW / img.width, maxH / img.height);
                    bmp.scaleX = bmp.scaleY = scale;

                    iconLayer.addChild(bmp);
                    updateSingleIconPosition(bmp);   // set vị trí ban đầu
                    stage.update();
                };
            }

            // KIM Ở GIỮA (đặt sau icon để nằm trên cùng)
            centerRota = new createjs.Bitmap(imgCenterRota);
            centerRota.regX = imgCenterRota.width / 2;
            centerRota.regY = imgCenterRota.height / 2;
            centerRota.scaleX = 0.5;
            centerRota.scaleY = 0.5;
            centerRota.x = 0;
            centerRota.y = 0;
            imgCoverRota.addChild(centerRota);

            stage.update();
        }

        function updateSingleIconPosition(bmp) {
            if (!bmp || bmp.__slotIndex == null) return;
            if (!imgContainRota || !imgContainRota.complete) return;

            var wheelRadius = imgContainRota.width / 2;
            var r = wheelRadius - ICON_OFFSET;

            var slotIndex = bmp.__slotIndex;
            var baseAngle = baseAngles[slotIndex] || 0;

            // imgRotation.rotation là góc hiện tại của bánh
            var currentWheelDeg = imgRotation ? imgRotation.rotation : 0;
            var angleDeg = baseAngle + currentWheelDeg;
            var angleRad = angleDeg * Math.PI / 180;

            bmp.x = Math.sin(angleRad) * r;
            bmp.y = -Math.cos(angleRad) * r;

            // giữ icon luôn đứng thẳng
            bmp.rotation = 0;
        }

        function updateAllIconsPosition() {
            if (!iconLayer) return;
            for (let i = 0; i < iconLayer.numChildren; i++) {
                updateSingleIconPosition(iconLayer.getChildAt(i));
            }
        }


        function handleResize() {
            if (!stage || !imgCoverRota || !imgContainRota.complete) return;

            var maxSize = 370;
            var canvas = stage.canvas;
            var minSize = 220;

            var size = Math.min(window.innerWidth - 40, maxSize);
            size = Math.max(minSize, size);

            canvas.width = size;
            canvas.height = size;

            imgCoverRota.x = canvas.width / 2;
            imgCoverRota.y = canvas.height / 2;

            var scale = size / imgContainRota.width;
            imgCoverRota.scaleX = scale;
            imgCoverRota.scaleY = scale;

            stage.update();
        }

        function stopWithResult(indexItem) {
            if (!spinning) return;
            spinningContinuous = false;

            var resultAngle = 360 - (degItem * indexItem + degItem / 2);

            var current = imgRotation.rotation;
            var curNorm = ((current % 360) + 360) % 360;

            var delta = (resultAngle - curNorm + 360) % 360;
            var target = current + totalRota * 360 + delta;

            createjs.Tween.removeTweens(imgRotation);
            createjs.Tween.get(imgRotation, { override: true })
                .to({ rotation: target }, timeRota, createjs.Ease.getPowOut(3))
                .call(function () { endRota(indexItem); });
        }

        function endRota(indexItem) {
            spinning = false;
            spinningContinuous = false;
            pointerEffectStop();
            setSpinButtonState(false);

            var itemResult = arrItem[indexItem];

            $('#img_result_spin').attr('src', linkImg + item_random_file + "/" + itemResult.src + ".png");
            $('#name_result_spin').text(itemResult.name);

            setTimeout(function () {
                document.querySelector('.screen-3').style.display = 'none';
                document.querySelector('.screen-4').style.display = '';
            }, 800);
        }

        function startPointerShake() {
            if (!centerRota) return;
            createjs.Tween.removeTweens(centerRota);
            createjs.Tween.get(centerRota, { loop: true })
                .to({ rotation: -4 }, 120, createjs.Ease.sineInOut)
                .to({ rotation: 4 }, 240, createjs.Ease.sineInOut)
                .to({ rotation: 0 }, 120, createjs.Ease.sineInOut);
        }
        function pointerEffectStop() {
            if (!centerRota) return;
            createjs.Tween.removeTweens(centerRota);
            createjs.Tween.get(centerRota).to({ rotation: 0 }, 60, createjs.Ease.quadInOut);
        }

        function getRandomInt(min, max) {
            min = Math.ceil(min);
            max = Math.floor(max);
            return Math.floor(Math.random() * (max - min + 1)) + min;
        }

        // format tiền VNĐ
        function formatVnMoney(v) {
            v = Number(v) || 0;
            return v.toLocaleString("vi-VN") + " ₫";
        }

        // ====== TÍCH HỢP API – SPIN_PROXY ======
        const SPIN_PROXY = '<%= ResolveUrl("~/Proxy/SpinProxy.ashx") %>';

        var arrItem = [];
        var totalItem = 0;
        var degItem = 0;
        var currentSpinTurnId = null;

        function loadSpinConfig() {
            return fetch(SPIN_PROXY + '?action=config', {
                method: 'GET',
                credentials: 'include',
                cache: 'no-store'
            })
                .then(async r => {
                    if (!r.ok) {
                        const txt = await r.text().catch(() => '');
                        console.error('config error', r.status, txt);
                        throw new Error('Không lấy được cấu hình vòng quay (HTTP ' + r.status + ')');
                    }
                    return r.json();
                })
                .then(cfg => {
                    arrItem = (cfg.items || []).map(function (it, idx) {
                        const iconKey =
                            it.icon_key ??
                            it.iconKey ??
                            it.icon_Key;

                        const rewardType =
                            it.reward_type ??
                            it.rewardType ??
                            it.reward_Type;

                        const rewardValue =
                            it.reward_value ??
                            it.rewardValue ??
                            it.reward_Value;

                        return {
                            config_item_id: it.id ?? it.Id,
                            name: it.label ?? it.Label,
                            src: iconKey || ('item' + (idx + 1)),
                            font: "12px utmavobold",
                            color: "#603913",
                            display: idx + 1,
                            index: idx + 1,
                            reward_type: rewardType,
                            reward_value: rewardValue
                        };
                    });

                    totalItem = arrItem.length;
                    degItem = 360 / Math.max(totalItem, 1);

                    if (imgContainRota.complete && imgCenterRota.complete) {
                        buildWheel();
                    }
                })
                .catch(err => {
                    console.error(err);
                    alert(err.message || 'Vòng quay chưa sẵn sàng, vui lòng thử lại.');
                });
        }

        function getAvailableSpinTurn() {
            return fetch(SPIN_PROXY + '?action=turns', {
                method: 'GET',
                credentials: 'include',
                cache: 'no-store'
            })
                .then(r => {
                    if (r.status === 401) {
                        hasLogin = false;
                        remainingSpins = 0;
                        updateSpinTurnsLabel();
                        throw new Error('Bạn cần đăng nhập để tham gia vòng quay.');
                    }
                    return r.json();
                })
                .then(list => {
                    hasLogin = true;
                    var available = (list || []).filter(function (x) {
                        var st = x.status ?? x.Status;
                        return st === 0;
                    });

                    remainingSpins = available.length;
                    updateSpinTurnsLabel();

                    if (!available.length) throw new Error('Bạn đã sử dụng hết lượt quay.');
                    var first = available[0];
                    return first.id ?? first.Id;
                });
        }

        function callSpinRoll(spinTurnId) {
            return fetch(SPIN_PROXY + '?action=roll&turnId=' + encodeURIComponent(spinTurnId), {
                method: 'POST',
                credentials: 'include',
                cache: 'no-store'
            })
                .then(r => {
                    if (r.status === 401) throw new Error('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.');
                    return r.json();
                });
        }

        function clickSpinRota() {
            if (spinning) return;
            if (totalItem <= 0) {
                alert('Vòng quay chưa sẵn sàng, vui lòng thử lại.');
                return;
            }

            $('#spin_result_message').text('').hide();

            spinning = true;
            spinningContinuous = true;
            setSpinButtonState(true);
            startPointerShake();

            getAvailableSpinTurn()
                .then(function (turnId) {
                    currentSpinTurnId = turnId;
                    return callSpinRoll(turnId);
                })
                .then(function (res) {
                    console.log("Spin result:", res);

                    var success = res.success ?? res.Success;
                    if (!success) {
                        var errMsg =
                            res.error_message ??
                            res.error_Message ??
                            res.message ??
                            'Quay thất bại.';
                        throw new Error(errMsg);
                    }

                    var configItemId =
                        res.config_item_id ??
                        res.configItemId ??
                        res.config_Item_Id;

                    var idx = -1;
                    if (configItemId != null) {
                        idx = arrItem.findIndex(function (x) {
                            return x.config_item_id === configItemId;
                        });
                    }
                    if (idx < 0) {
                        idx = getRandomInt(0, totalItem - 1);
                    }

                    var itemResult = arrItem[idx];

                    $('#img_result_spin').attr('src', linkImg + item_random_file + "/" + itemResult.src + ".png");
                    $('#name_result_spin').text(itemResult.name);

                    // ==== THÔNG BÁO THEO LOẠI THƯỞNG ====
                    var rt =
                        res.reward_type ??
                        res.rewardType ??
                        res.reward_Type;

                    var pointsAdded =
                        res.points_added ??
                        res.pointsAdded ??
                        res.points_Added;

                    var totalPoints =
                        res.total_points ??
                        res.totalPoints ??
                        res.total_Points;

                    var extraSpins =
                        res.extra_spins_created ??
                        res.extraSpinsCreated ??
                        res.extra_Spins_Created;

                    // voucher thực tế
                    var promoCode =
                        res.promotion_code ??
                        res.promotionCode ??
                        res.promotion_Code;

                    var minAmount =
                        res.min_order_amount ??
                        res.minOrderAmount ??
                        res.min_Order_Amount;

                    var msg = '';
                    if (rt === 2 && pointsAdded > 0) {
                        msg = 'Bạn nhận được ' + pointsAdded + ' điểm thưởng'
                            + (totalPoints != null ? ' (tổng điểm hiện tại: ' + totalPoints + ')' : '')
                            + ' 🎉';
                    } else if (rt === 3 && extraSpins > 0) {
                        msg = 'Tuyệt vời! Bạn nhận thêm ' + extraSpins + ' lượt quay nữa 🎁';
                    } else if (rt === 4) {
                        msg = 'Chúc bạn may mắn lần sau nhé 🍀';
                    } else if (rt === 1 && promoCode) {
                        msg = 'Bạn nhận được mã khuyến mãi '
                            + promoCode
                            + (minAmount != null
                                ? ' cho đơn từ ' + formatVnMoney(minAmount) + ' trở lên'
                                : '')
                            + '. Nhập mã này ở bước thanh toán nhé 🎫';
                    }

                    // cập nhật lại remainingSpins (1 lượt đã dùng + có thể được thêm)
                    if (remainingSpins != null) {
                        remainingSpins = Math.max(0, remainingSpins - 1 + (extraSpins || 0));
                        updateSpinTurnsLabel();
                    }

                    if (msg) {
                        $('#spin_result_message').text(msg).show();
                    }

                    stopWithResult(idx);
                })
                .catch(function (err) {
                    console.error(err);
                    pointerEffectStop();
                    spinning = false;
                    spinningContinuous = false;
                    setSpinButtonState(false);
                    alert(err.message || 'Không quay được, vui lòng thử lại.');
                });
        }

        function backToWheel() {
            document.querySelector('.screen-3').style.display = '';
            document.querySelector('.screen-4').style.display = 'none';
            $('#spin_result_message').text('').hide();
        }

        window.addEventListener('load', function () {
            init();
            loadSpinConfig();

            getAvailableSpinTurn().catch(function (e) {
                console.log(e.message);
            });
        });
    </script>
</form>
</body>
</html>
