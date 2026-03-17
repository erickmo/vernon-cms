class AppStrings {
  AppStrings._();

  static const String loading = 'Memuat...';
  static const String retry = 'Coba Lagi';
  static const String cancel = 'Batal';
  static const String save = 'Simpan';
  static const String delete = 'Hapus';
  static const String edit = 'Edit';
  static const String create = 'Tambah';
  static const String search = 'Cari...';
  static const String confirm = 'Konfirmasi';
  static const String yes = 'Ya';
  static const String no = 'Tidak';
  static const String close = 'Tutup';
  static const String back = 'Kembali';
  static const String detail = 'Detail';
  static const String active = 'Aktif';
  static const String inactive = 'Nonaktif';

  static const String errorGeneral = 'Terjadi kesalahan. Silakan coba lagi.';
  static const String errorNetwork = 'Tidak ada koneksi internet.';
  static const String errorServer = 'Server sedang bermasalah.';
  static const String errorUnauthorized = 'Sesi berakhir. Silakan login kembali.';
  static const String errorNotFound = 'Data tidak ditemukan.';

  static const String emptyData = 'Belum ada data.';
  static const String emptySearch = 'Hasil pencarian tidak ditemukan.';

  // Auth
  static const String login = 'Login';
  static const String logout = 'Keluar';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String loginButton = 'Masuk';
  static const String loginTitle = 'Vernon Admin';
  static const String loginSubtitle = 'Masuk untuk mengelola clients dan payments';

  // Sidebar
  static const String menuDashboard = 'Dashboard';
  static const String menuClients = 'Clients';
  static const String menuPayments = 'Payments';

  // Client
  static const String clients = 'Clients';
  static const String clientCreate = 'Tambah Client';
  static const String clientEdit = 'Edit Client';
  static const String clientDetail = 'Detail Client';
  static const String clientName = 'Nama Client';
  static const String clientEmail = 'Email';
  static const String clientPhone = 'No. Telepon';
  static const String clientAddress = 'Alamat';
  static const String clientCompany = 'Perusahaan';
  static const String clientStatus = 'Status';
  static const String clientToggleActive = 'Aktifkan Client';
  static const String clientToggleInactive = 'Nonaktifkan Client';
  static const String clientDeleteConfirm = 'Hapus client ini?';
  static const String clientCreated = 'Client berhasil ditambahkan';
  static const String clientUpdated = 'Client berhasil diperbarui';
  static const String clientDeleted = 'Client berhasil dihapus';
  static const String clientToggled = 'Status client berhasil diubah';

  // Payment
  static const String payments = 'Payments';
  static const String paymentCreate = 'Tambah Payment';
  static const String paymentDetail = 'Detail Payment';
  static const String paymentAmount = 'Jumlah';
  static const String paymentStatus = 'Status';
  static const String paymentClient = 'Client';
  static const String paymentDescription = 'Keterangan';
  static const String paymentDueDate = 'Jatuh Tempo';
  static const String paymentPaidAt = 'Tanggal Bayar';
  static const String paymentMethod = 'Metode Pembayaran';
  static const String paymentCreated = 'Payment berhasil ditambahkan';
  static const String filterAll = 'Semua';
  static const String filterPending = 'Pending';
  static const String filterPaid = 'Lunas';
  static const String filterFailed = 'Gagal';
  static const String filterCancelled = 'Dibatalkan';
}
