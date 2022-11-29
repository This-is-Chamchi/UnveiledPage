using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.Animations.Rigging;

public enum FlipMode
{ 
    RightToLeft,
    LeftToRight,
}

[ExecuteInEditMode]
public class Book : MonoBehaviour
{
    private Canvas canvas;

    [SerializeField] private RectTransform bookPanel;
    [SerializeField] private Sprite backGround;
    [SerializeField] private Sprite[] bookPages;
    [SerializeField] private bool interactable = true;
    [SerializeField] private bool enableShadowEffect = true;

    [SerializeField] private int currentPage = 0;
    public int totoalPageCount
    {
        get { return bookPages.Length; }
    }

    public Vector3 EndBottomLeft
    {
        get { return ebl; }
    }
    public Vector3 EndBottomRight
    {
        get { return ebr; }
    }
    public float Hight
    {
        get { return bookPanel.rect.height; }
    }

    public Image clippingPlane;
    public Image nextPageClip;
    public Image shadow;
    public Image shadowLTR;
    public Image left;
    public Image leftNext;
    public Image right;
    public Image rightNext;
    public UnityEvent onFlip;
    float radius1, radius2;

    private Vector3 sb;
    private Vector3 st;
    private Vector3 c;
    private Vector3 ebr;
    private Vector3 ebl;
    private Vector3 f;

    private bool pageDragging = false;

    private FlipMode mode;

    void Start()
    {
        if (!canvas) canvas = GetComponentInParent<Canvas>();
        if (!canvas) Debug.LogError("Book should be a child to canvas");

        left.gameObject.SetActive(false);
        right.gameObject.SetActive(false);
        UpdateSprites();
        CalcCurlCriticalPoints();

        float pageWidth = bookPanel.rect.width / 2.0f;
        float pageHeight = bookPanel.rect.height;
        nextPageClip.rectTransform.sizeDelta = new Vector2(pageWidth, pageHeight + pageHeight * 2);


        clippingPlane.rectTransform.sizeDelta = new Vector2(pageWidth * 2 + pageHeight, pageHeight + pageHeight * 2);

        //hypotenous (diagonal) page length
        float hyp = Mathf.Sqrt(pageWidth * pageWidth + pageHeight * pageHeight);
        float shadowPageHeight = pageWidth / 2 + hyp;

        shadow.rectTransform.sizeDelta = new Vector2(pageWidth, shadowPageHeight);
        shadow.rectTransform.pivot = new Vector2(1, (pageWidth / 2) / shadowPageHeight);

        shadowLTR.rectTransform.sizeDelta = new Vector2(pageWidth, shadowPageHeight);
        shadowLTR.rectTransform.pivot = new Vector2(0, (pageWidth / 2) / shadowPageHeight);

    }

    private void CalcCurlCriticalPoints()
    {
        sb = new Vector3(0, -bookPanel.rect.height / 2);
        ebr = new Vector3(bookPanel.rect.width / 2, -bookPanel.rect.height / 2);
        ebl = new Vector3(-bookPanel.rect.width / 2, -bookPanel.rect.height / 2);
        st = new Vector3(0, bookPanel.rect.height / 2);
        radius1 = Vector2.Distance(sb, ebr);
        float pageWidth = bookPanel.rect.width / 2.0f;
        float pageHeight = bookPanel.rect.height;
        radius2 = Mathf.Sqrt(pageWidth * pageWidth + pageHeight * pageHeight);
    }

    public Vector3 transformPoint(Vector3 mouseScreenPos)
    {
        if (canvas.renderMode == RenderMode.ScreenSpaceCamera)
        {
            Vector3 mouseWorldPos = canvas.worldCamera.ScreenToWorldPoint(new Vector3(mouseScreenPos.x, mouseScreenPos.y, canvas.planeDistance));
            Vector2 localPos = bookPanel.InverseTransformPoint(mouseWorldPos);

            return localPos;
        }
        else if (canvas.renderMode == RenderMode.WorldSpace)
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            Vector3 globalEBR = transform.TransformPoint(ebr);
            Vector3 globalEBL = transform.TransformPoint(ebl);
            Vector3 globalSt = transform.TransformPoint(st);
            Plane p = new Plane(globalEBR, globalEBL, globalSt);
            float distance;
            p.Raycast(ray, out distance);
            Vector2 localPos = bookPanel.InverseTransformPoint(ray.GetPoint(distance));
            return localPos;
        }
        else
        {
            //Screen Space Overlay
            Vector2 localPos = bookPanel.InverseTransformPoint(mouseScreenPos);
            return localPos;
        }
    }
    void Update()
    {
        if (pageDragging && interactable)
        {
            UpdateBook();
        }
    }
    public void UpdateBook()
    {
        f = Vector3.Lerp(f, transformPoint(Input.mousePosition), Time.deltaTime * 10);
        if (mode == FlipMode.RightToLeft)
            UpdateBookRTLToPoint(f);
        else
            UpdateBookLTRToPoint(f);
    }
    public void UpdateBookLTRToPoint(Vector3 followLocation)
    {
        mode = FlipMode.LeftToRight;
        f = followLocation;
        shadowLTR.transform.SetParent(clippingPlane.transform, true);
        shadowLTR.transform.localPosition = new Vector3(0, 0, 0);
        shadowLTR.transform.localEulerAngles = new Vector3(0, 0, 0);
        left.transform.SetParent(clippingPlane.transform, true);

        right.transform.SetParent(bookPanel.transform, true);
        right.transform.localEulerAngles = Vector3.zero;
        leftNext.transform.SetParent(bookPanel.transform, true);

        c = Calc_C_Position(followLocation);
        Vector3 t1;
        float clipAngle = CalcClipAngle(c, ebl, out t1);
        //0 < T0_T1_Angle < 180
        clipAngle = (clipAngle + 180) % 180;

        clippingPlane.transform.localEulerAngles = new Vector3(0, 0, clipAngle - 90);
        clippingPlane.transform.position = bookPanel.TransformPoint(t1);

        //page position and angle
        left.transform.position = bookPanel.TransformPoint(c);
        float C_T1_dy = t1.y - c.y;
        float C_T1_dx = t1.x - c.x;
        float C_T1_Angle = Mathf.Atan2(C_T1_dy, C_T1_dx) * Mathf.Rad2Deg;
        left.transform.localEulerAngles = new Vector3(0, 0, C_T1_Angle - 90 - clipAngle);

        nextPageClip.transform.localEulerAngles = new Vector3(0, 0, clipAngle - 90);
        nextPageClip.transform.position = bookPanel.TransformPoint(t1);
        leftNext.transform.SetParent(nextPageClip.transform, true);
        right.transform.SetParent(clippingPlane.transform, true);
        right.transform.SetAsFirstSibling();

        shadowLTR.rectTransform.SetParent(left.rectTransform, true);
    }
    public void UpdateBookRTLToPoint(Vector3 followLocation)
    {
        mode = FlipMode.RightToLeft;
        f = followLocation;
        shadow.transform.SetParent(clippingPlane.transform, true);
        shadow.transform.localPosition = Vector3.zero;
        shadow.transform.localEulerAngles = Vector3.zero;
        right.transform.SetParent(clippingPlane.transform, true);

        left.transform.SetParent(bookPanel.transform, true);
        left.transform.localEulerAngles = Vector3.zero;
        rightNext.transform.SetParent(bookPanel.transform, true);
        c = Calc_C_Position(followLocation);
        Vector3 t1;
        float clipAngle = CalcClipAngle(c, ebr, out t1);
        if (clipAngle > -90) clipAngle += 180;

        clippingPlane.rectTransform.pivot = new Vector2(1, 0.35f);
        clippingPlane.transform.localEulerAngles = new Vector3(0, 0, clipAngle + 90);
        clippingPlane.transform.position = bookPanel.TransformPoint(t1);

        //page position and angle
        right.transform.position = bookPanel.TransformPoint(c);
        float C_T1_dy = t1.y - c.y;
        float C_T1_dx = t1.x - c.x;
        float C_T1_Angle = Mathf.Atan2(C_T1_dy, C_T1_dx) * Mathf.Rad2Deg;
        right.transform.localEulerAngles = new Vector3(0, 0, C_T1_Angle - (clipAngle + 90));

        nextPageClip.transform.localEulerAngles = new Vector3(0, 0, clipAngle + 90);
        nextPageClip.transform.position = bookPanel.TransformPoint(t1);
        rightNext.transform.SetParent(nextPageClip.transform, true);
        left.transform.SetParent(clippingPlane.transform, true);
        left.transform.SetAsFirstSibling();

        shadow.rectTransform.SetParent(right.rectTransform, true);
    }
    private float CalcClipAngle(Vector3 c, Vector3 bookCorner, out Vector3 t1)
    {
        Vector3 t0 = (c + bookCorner) / 2;
        float T0_CORNER_dy = bookCorner.y - t0.y;
        float T0_CORNER_dx = bookCorner.x - t0.x;
        float T0_CORNER_Angle = Mathf.Atan2(T0_CORNER_dy, T0_CORNER_dx);
        float T0_T1_Angle = 90 - T0_CORNER_Angle;

        float T1_X = t0.x - T0_CORNER_dy * Mathf.Tan(T0_CORNER_Angle);
        T1_X = normalizeT1X(T1_X, bookCorner, sb);
        t1 = new Vector3(T1_X, sb.y, 0);

        //clipping plane angle=T0_T1_Angle
        float T0_T1_dy = t1.y - t0.y;
        float T0_T1_dx = t1.x - t0.x;
        T0_T1_Angle = Mathf.Atan2(T0_T1_dy, T0_T1_dx) * Mathf.Rad2Deg;
        return T0_T1_Angle;
    }
    private float normalizeT1X(float t1, Vector3 corner, Vector3 sb)
    {
        if (t1 > sb.x && sb.x > corner.x)
            return sb.x;
        if (t1 < sb.x && sb.x < corner.x)
            return sb.x;
        return t1;
    }
    private Vector3 Calc_C_Position(Vector3 followLocation)
    {
        Vector3 c;
        f = followLocation;
        float F_SB_dy = f.y - sb.y;
        float F_SB_dx = f.x - sb.x;
        float F_SB_Angle = Mathf.Atan2(F_SB_dy, F_SB_dx);
        Vector3 r1 = new Vector3(radius1 * Mathf.Cos(F_SB_Angle), radius1 * Mathf.Sin(F_SB_Angle), 0) + sb;

        float F_SB_distance = Vector2.Distance(f, sb);
        if (F_SB_distance < radius1)
            c = f;
        else
            c = r1;
        float F_ST_dy = c.y - st.y;
        float F_ST_dx = c.x - st.x;
        float F_ST_Angle = Mathf.Atan2(F_ST_dy, F_ST_dx);
        Vector3 r2 = new Vector3(radius2 * Mathf.Cos(F_ST_Angle),
           radius2 * Mathf.Sin(F_ST_Angle), 0) + st;
        float C_ST_distance = Vector2.Distance(c, st);
        if (C_ST_distance > radius2)
            c = r2;
        return c;
    }
    public void DragRightPageToPoint(Vector3 point)
    {
        if (currentPage >= bookPages.Length) return;
        pageDragging = true;
        mode = FlipMode.RightToLeft;
        f = point;


        nextPageClip.rectTransform.pivot = new Vector2(0, 0.12f);
        clippingPlane.rectTransform.pivot = new Vector2(1, 0.35f);

        left.gameObject.SetActive(true);
        left.rectTransform.pivot = new Vector2(0, 0);
        left.transform.position = rightNext.transform.position;
        left.transform.eulerAngles = new Vector3(0, 0, 0);
        left.sprite = (currentPage < bookPages.Length) ? bookPages[currentPage] : backGround;
        left.transform.SetAsFirstSibling();

        right.gameObject.SetActive(true);
        right.transform.position = rightNext.transform.position;
        right.transform.eulerAngles = new Vector3(0, 0, 0);
        right.sprite = (currentPage < bookPages.Length - 1) ? bookPages[currentPage + 1] : backGround;

        rightNext.sprite = (currentPage < bookPages.Length - 2) ? bookPages[currentPage + 2] : backGround;

        leftNext.transform.SetAsFirstSibling();
        if (enableShadowEffect) shadow.gameObject.SetActive(true);
        UpdateBookRTLToPoint(f);
    }
    public void OnMouseDragRightPage()
    {
        if (interactable)
            DragRightPageToPoint(transformPoint(Input.mousePosition));

    }
    public void DragLeftPageToPoint(Vector3 point)
    {
        if (currentPage <= 0) return;
        pageDragging = true;
        mode = FlipMode.LeftToRight;
        f = point;

        nextPageClip.rectTransform.pivot = new Vector2(1, 0.12f);
        clippingPlane.rectTransform.pivot = new Vector2(0, 0.35f);

        right.gameObject.SetActive(true);
        right.transform.position = leftNext.transform.position;
        right.sprite = bookPages[currentPage - 1];
        right.transform.eulerAngles = new Vector3(0, 0, 0);
        right.transform.SetAsFirstSibling();

        left.gameObject.SetActive(true);
        left.rectTransform.pivot = new Vector2(1, 0);
        left.transform.position = leftNext.transform.position;
        left.transform.eulerAngles = new Vector3(0, 0, 0);
        left.sprite = (currentPage >= 2) ? bookPages[currentPage - 2] : backGround;

        leftNext.sprite = (currentPage >= 3) ? bookPages[currentPage - 3] : backGround;

        rightNext.transform.SetAsFirstSibling();
        if (enableShadowEffect) shadowLTR.gameObject.SetActive(true);
        UpdateBookLTRToPoint(f);
    }
    public void OnMouseDragLeftPage()
    {
        if (interactable)
            DragLeftPageToPoint(transformPoint(Input.mousePosition));

    }
    public void OnMouseRelease()
    {
        if (interactable)
            ReleasePage();
    }
    public void ReleasePage()
    {
        if (pageDragging)
        {
            pageDragging = false;
            float distanceToLeft = Vector2.Distance(c, ebl);
            float distanceToRight = Vector2.Distance(c, ebr);
            if (distanceToRight < distanceToLeft && mode == FlipMode.RightToLeft)
                TweenBack();
            else if (distanceToRight > distanceToLeft && mode == FlipMode.LeftToRight)
                TweenBack();
            else
                TweenForward();
        }
    }
    Coroutine currentCoroutine;
    void UpdateSprites()
    {
        leftNext.sprite = (currentPage > 0 && currentPage <= bookPages.Length) ? bookPages[currentPage - 1] : backGround;
        rightNext.sprite = (currentPage >= 0 && currentPage < bookPages.Length) ? bookPages[currentPage] : backGround;
    }
    public void TweenForward()
    {
        if (mode == FlipMode.RightToLeft)
            currentCoroutine = StartCoroutine(TweenTo(ebl, 0.15f, () => { Flip(); }));
        else
            currentCoroutine = StartCoroutine(TweenTo(ebr, 0.15f, () => { Flip(); }));
    }
    void Flip()
    {
        if (mode == FlipMode.RightToLeft)
            currentPage += 2;
        else
            currentPage -= 2;
        leftNext.transform.SetParent(bookPanel.transform, true);
        left.transform.SetParent(bookPanel.transform, true);
        leftNext.transform.SetParent(bookPanel.transform, true);
        left.gameObject.SetActive(false);
        right.gameObject.SetActive(false);
        right.transform.SetParent(bookPanel.transform, true);
        rightNext.transform.SetParent(bookPanel.transform, true);
        UpdateSprites();
        shadow.gameObject.SetActive(false);
        shadowLTR.gameObject.SetActive(false);
        if (onFlip != null)
            onFlip.Invoke();
    }
    public void TweenBack()
    {
        if (mode == FlipMode.RightToLeft)
        {
            currentCoroutine = StartCoroutine(TweenTo(ebr, 0.15f,
                () =>
                {
                    UpdateSprites();
                    rightNext.transform.SetParent(bookPanel.transform);
                    right.transform.SetParent(bookPanel.transform);

                    left.gameObject.SetActive(false);
                    right.gameObject.SetActive(false);
                    pageDragging = false;
                }
                ));
        }
        else
        {
            currentCoroutine = StartCoroutine(TweenTo(ebl, 0.15f,
                () =>
                {
                    UpdateSprites();

                    leftNext.transform.SetParent(bookPanel.transform);
                    left.transform.SetParent(bookPanel.transform);

                    left.gameObject.SetActive(false);
                    right.gameObject.SetActive(false);
                    pageDragging = false;
                }
                ));
        }
    }
    public IEnumerator TweenTo(Vector3 to, float duration, System.Action onFinish)
    {
        int steps = (int)(duration / 0.025f);
        Vector3 displacement = (to - f) / steps;
        for (int i = 0; i < steps - 1; i++)
        {
            if (mode == FlipMode.RightToLeft)
                UpdateBookRTLToPoint(f + displacement);
            else
                UpdateBookLTRToPoint(f + displacement);

            yield return new WaitForSeconds(0.025f);
        }
        if (onFinish != null)
            onFinish();
    }
}
