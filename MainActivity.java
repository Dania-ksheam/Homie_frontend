// import android.Manifest;
// import android.content.pm.PackageManager;
// import androidx.core.app.ActivityCompat;
// import androidx.core.content.ContextCompat;

// private static final int PERMISSION_REQUEST_CODE = 100;

// @Override
// protected void onCreate(Bundle savedInstanceState) {
//     super.onCreate(savedInstanceState);
//     setContentView(R.layout.activity_main);

//     // Check and request permissions
//     checkPermissions();

//     imageView = findViewById(R.id.imageView);
//     pickImageButton = findViewById(R.id.pickImageButton);

//     pickImageButton.setOnClickListener(v -> openGallery());
// }

// private void checkPermissions() {
//     if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) 
//             != PackageManager.PERMISSION_GRANTED) {
//         ActivityCompat.requestPermissions(this, 
//             new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, 
//             PERMISSION_REQUEST_CODE);
//     }
// }

// @Override
// public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
//     super.onRequestPermissionsResult(requestCode, permissions, grantResults);
//     if (requestCode == PERMISSION_REQUEST_CODE) {
//         if (grantResults.length > 0 && grantResults[0] != PackageManager.PERMISSION_GRANTED) {
//             // Handle the case where permission is denied
//             // Maybe show a message to the user
//         }
//     }
// }
