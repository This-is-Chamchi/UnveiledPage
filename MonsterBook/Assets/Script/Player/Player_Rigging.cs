using UnityEngine;
using UnityEngine.Animations.Rigging;
 
public class Player_Rigging : MonoBehaviour {
    #region inspector
    [SerializeField] protected MultiParentConstraint m_FootRef_Constraint;
    [SerializeField] protected TwoBoneIKConstraint m_FootIKSet;
    [SerializeField] protected Transform m_IKTarget;

//===========================================================================//

    [Range(0,1)][SerializeField] protected float m_Ray_Y_Offset = 0.5f;
    [Range(0,2)][SerializeField] protected float m_Ray_Distance = 1f;
    [Range(0,0.5f)][SerializeField] protected float m_Planted_Y_Offset = 0.17f;

//===========================================================================//
[Space(20)]
    [SerializeField] private LayerMask m_GroundMask;
    private Vector3 m_RayOrigin;
 
 #endregion

    protected void Start(){m_FootRef_Constraint.weight = 1;}

    protected void LateUpdate(){SetRayWithFoot();}


    protected void SetRayWithFoot() {
        m_FootIKSet.weight = 0;

        transform.position = m_FootRef_Constraint.transform.position;
        m_RayOrigin = transform.position + Vector3.up * m_Ray_Y_Offset;
        var FootPos = m_FootRef_Constraint.transform.position;
 
        if (Physics.Raycast(m_RayOrigin, Vector3.down, out var Hit, m_Ray_Distance, m_GroundMask))  {
            var HitPosY = Hit.point.y + m_Planted_Y_Offset;
            if (FootPos.y != HitPosY)   {
                m_FootIKSet.weight = 1;
                var Pos = Hit.point;
                Pos.y += m_Planted_Y_Offset;
                m_IKTarget.position = Pos;
                var TargetRot = Quaternion.FromToRotation(Vector3.up, Hit.normal) * m_FootRef_Constraint.transform.rotation;
                m_IKTarget.rotation = TargetRot;
            }
        }
        Debug.DrawRay(m_RayOrigin, Vector3.down * m_Ray_Distance, Color.red);
    }
}