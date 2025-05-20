using UnityEngine;

public class Camera : MonoBehaviour
{
    public float moveSpeed = 10f;
    public float lookSpeed = 2f;
    public float boostMultiplier = 2f;

    float rotationX = 0f;
    float rotationY = 0f;

    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    void Update()
    {
        float moveX = Input.GetAxis("Horizontal");
        float moveZ = Input.GetAxis("Vertical");
        float moveY = 0f;

        float speed = Input.GetKey(KeyCode.LeftShift) ? moveSpeed * boostMultiplier : moveSpeed;

        Vector3 move = transform.right * moveX + transform.up * moveY + transform.forward * moveZ;
        transform.position += move * speed * Time.deltaTime;

        rotationX += Input.GetAxis("Mouse X") * lookSpeed;
        rotationY -= Input.GetAxis("Mouse Y") * lookSpeed;

        transform.rotation = Quaternion.Euler(rotationY, rotationX, 0f);
    }
}