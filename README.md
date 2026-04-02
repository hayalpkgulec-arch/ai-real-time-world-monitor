# AI Real-Time World Monitor

Bu proje, yapay zeka destekli gerçek zamanlı dünya izleme sistemi için bir prototiptir. Amacı, çeşitli veri kaynaklarından gelen bilgileri toplayarak, analiz ederek ve anlamlandırarak dünya genelindeki olayları, trendleri ve gelişmeleri anlık olarak takip etmektir.

## 🚀 Özellikler

- **Gerçek Zamanlı Veri Toplama**: Çeşitli API'ler, haber kaynakları ve sosyal medya platformlarından anlık veri akışı
- **Yapay Zeka Destekli Analiz**: Doğal dil işleme (NLP) ve makine öğrenmesi modelleri kullanarak verilerin anlamlandırılması, duygu analizi ve trend tespiti
- **Etkileşimli Dashboard**: Kullanıcı dostu bir arayüz ile toplanan verilerin görselleştirilmesi ve özelleştirilebilir raporlar
- **Uyarı ve Bildirim Sistemi**: Belirlenen kriterlere göre önemli olaylar veya anomaliler hakkında otomatik bildirimler
- **Ölçeklenebilir Mimari**: Büyük veri hacimlerini işleyebilecek ve gelecekteki genişlemelere uyum sağlayabilecek esnek bir yapı

## 🛠️ Teknolojiler

- **Frontend**: Flutter (Web, Mobil, Desktop)
- **Backend**: Node.js (Express API)
- **Veritabanı**: PostgreSQL, MongoDB
- **Yapay Zeka/Makine Öğrenimi**: OpenAI, Groq, Mistral AI
- **Bulut Platformları**: Railway (Production), AWS, Google Cloud Platform

## 📦 Kurulum

### Ön Gereksinimler

- Git
- Flutter SDK
- Node.js
- API Keys (NewsAPI, OpenAI, vb.)

### Adımlar

1. **Projeyi Klonlayın**:
   ```bash
   git clone https://github.com/hayalpkgulec-arch/ai-real-time-world-monitor.git
   cd ai-real-time-world-monitor
   ```

2. **Frontend Kurulumu (Flutter)**:
   ```bash
   cd aegis_app
   flutter pub get
   flutter run
   ```

3. **Backend Kurulumu**:
   ```bash
   cd backend
   npm install
   npm start
   ```

## 🌐 Deployment

### Railway (Production)
```bash
cd aegis_app
flutter build web
# Build sonuçları Railway'e otomatik deploy olur
```

**Backend URL**: https://realtimeoworldmonitor-production.up.railway.app

## 📝 Kullanım

Proje, gerçek zamanlı dünya verilerini izlemek, analiz etmek ve görselleştirmek için tasarlanmıştır. Dashboard üzerinden çeşitli filtreler uygulayarak ve arama yaparak ilgi alanlarınıza göre bilgileri keşfedebilirsiniz.

### Ana Özellikler
- **Haber Akışı**: Gerçek zamanlı haberler ve olaylar
- **AI Analizi**: Haberlerin doğrulanma durumu ve güvenilirlik analizi
- **Kaynak Doğrulama**: Çoklu kaynak cross-reference kontrolü
- **Filtreleme**: Konu, ciddiyet ve zamana göre filtreleme
- **Real-time Bildirimler**: Önemli gelişmeler için anlık bildirimler

## 🔧 Konfigürasyon

### Environment Variables
```bash
# Backend API URL
BACKEND_URL=https://realtimeoworldmonitor-production.up.railway.app

# News API (haber kaynağı)
NEWS_API_KEY=your_newsapi_key_here

# AI API'leri
OPENAI_API_KEY=your_openai_api_key_here
MISTRAL_API_KEY=your_mistral_api_key_here
GROQ_API_KEY=your_groq_api_key_here
```

## 🤝 Katkıda Bulunma

Projenin geliştirilmesine katkıda bulunmaktan memnuniyet duyarız! Lütfen bir issue açın veya bir pull request gönderin.

### Katkı Süreci
1. Fork yapın
2. Feature branch oluşturun: `git checkout -b feature/yeni-ozellik`
3. Değişiklikleri yapın: `git commit -m "Yeni özellik eklendi"`
4. Push yapın: `git push origin feature/yeni-ozellik`
5. Pull request oluşturun

## 📊 Proje Durumu

### ✅ Tamamlanan Özellikler
- [x] Flutter web uygulaması
- [x] Gerçek zamanlı haber akışı
- [x] AI destekli analiz sistemi
- [x] Kaynak doğrulama
- [x] Queue-based processing
- [x] Railway deployment

### 🚧 Geliştirme Aşamasında
- [ ] Multi-source cross-reference
- [ ] Gelişmiş AI modelleri
- [ ] Mobil uygulama
- [ ] Real-time alerts
- [ ] Data export özellikleri

## 📄 Lisans

Bu proje MIT Lisansı altında lisanslanmıştır. Daha fazla bilgi için `LICENSE` dosyasına bakın.

## 📞 İletişim

Sorularınız veya geri bildirimleriniz için lütfen iletişime geçin:

- **GitHub**: https://github.com/hayalpkgulec-arch/ai-real-time-world-monitor/issues
- **Repository**: https://github.com/hayalpkgulec-arch/ai-real-time-world-monitor

---

⭐ **Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!**
