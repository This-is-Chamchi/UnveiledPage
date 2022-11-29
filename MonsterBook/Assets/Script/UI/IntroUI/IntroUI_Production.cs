using UnityEngine;


public class IntroUI_Production : MonoBehaviour {

    [SerializeField]protected Animator m_ani;
    protected int m_Count = 0;

    protected void Awake() {
        m_Count = 0;
        m_ani = GetComponent<Animator>();
    }

    protected void Update() {
        if(Input.GetKeyDown(KeyCode.T)){
            if(m_Count > 9) {
                return;
                }
            else    {
                m_Count += 1;

                m_ani.SetTrigger(""+m_Count);
            }
        }
    }
}
